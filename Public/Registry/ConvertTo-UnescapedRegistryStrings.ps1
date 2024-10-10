using namespace System.Text.RegularExpressions

function ConvertTo-UnescapedRegistryStrings {

    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]] $String
    )

    begin {
        $ValuesList = [System.Collections.Generic.List[Object]]@()
        $RegistryHiveAbbreviations = @{
            HKEY_CLASSES_ROOT   = 'HKCR'
            HKEY_CURRENT_USER   = 'HKCU'
            HKEY_LOCAL_MACHINE  = 'HKLM'
            HKEY_USERS          = 'HKU'
            HKEY_CURRENT_CONFIG = 'HKCC'
        }
    }

    process {

        $GroupRegistryKeys = {

            param ( [string] $Key )

            $KeyName = ""
            $Values = [System.Collections.Generic.List[String]]@()

            $ValuePatternKeyName    = [regex]'(?m)^\s*(\[.*\])\s*$'
            $ValuePatternDefault    = [regex]'(?m)^\s*@="(?:.*)"\s*$'
            $ValuePatternDefaultHex = [regex]'(?m)^@=hex\((7|2)\):[0-9a-fA-F,\\\s]+'
            $ValuePatternNamed      = [regex]'(?m)^\s*"(.*)"="(.*)"\s*$|(?m)^"(.*)"=hex\((7|2)\):[0-9a-fA-F,\\\s]+'

            [MatchCollection] $MKeyName = $ValuePatternKeyName.Matches($Key)
            [MatchCollection] $MDefault = $ValuePatternDefault.Matches($Key)
            [MatchCollection] $MDefaultHex = $ValuePatternDefaultHex.Matches($Key)
            [MatchCollection] $MNamed = $ValuePatternNamed.Matches($Key)

            if ($MDefault.Success)    { $Values.Add($MDefault.Groups[0].value) }
            if ($MDefaultHex.Success) { $Values.Add($MDefaultHex.Groups[0].value) }
            if ($MKeyName.Success)    { $KeyName = $MKeyName.Groups[1].Value }

            if ($MNamed.Success) {
                foreach ($Match in $MNamed) {
                    $Values.Add($Match.Value)
                }
            }

            [PSCustomObject]@{
                KeyName = $KeyName
                Values = $Values
            }
        }

        foreach ($CurrentRegString in $String) {

            $GroupedKeys = & $GroupRegistryKeys -Key $CurrentRegString
            if($GroupedKeys.KeyName){
                $RegistryKeyHeader = $GroupedKeys.KeyName
                $RegistryHiveLong = ($RegistryKeyHeader -split '\\')[0].TrimStart('[')
                $RegistryHiveShort = $RegistryHiveAbbreviations[$RegistryHiveLong]
            }

            foreach ($CurrentValue in $GroupedKeys.Values) {

                # Begin string type detection

                if($CurrentValue -like '*hex(7)*'){ $StringType = "REG_MULTI_SZ" }
                elseif($CurrentValue -like '*hex(2)*'){ $StringType = "REG_EXPAND_SZ" }
                elseif($CurrentValue -match '^@="'){ $StringType = "REG_SZ" }
                elseif($CurrentValue -match '^"(.*)"="'){ $StringType = "REG_SZ" }

                # Handle decoding of REG_SZ (String) #########################################################
                ##############################################################################################

                if($StringType -eq 'REG_SZ'){

                    $StringIsNamedRegex = [regex]'(?m)^"(.*)"='
                    $StringIsDefaultRegex = [regex]'(?m)^@='

                    $NamedString = $StringIsNamedRegex.Match($CurrentValue)
                    $DefaultString = $StringIsDefaultRegex.Match($CurrentValue)

                    if($NamedString.Success){
                        $CurrentValue = $StringIsNamedRegex.Replace($CurrentValue, '')
                        $ValueIsDefault = $false
                        $ValueName = $NamedString.Groups[1].Value
                    }
                    elseif($DefaultString.Success){
                        $CurrentValue = $StringIsDefaultRegex.Replace($CurrentValue, '')
                        $ValueIsDefault = $true
                        $ValueName = $null
                    }

                    $UnescapedValue = ConvertTo-RegSZUnescaped -String $CurrentValue

                    $obj = [PSCustomObject]@{
                        RegistryHive        = $RegistryHiveLong
                        RegistryHiveAbbv    = $RegistryHiveShort
                        RegistryKey         = $RegistryKeyHeader
                        OriginalType        = 'REG_SZ (String)'
                        ValueIsDefault      = $true
                        ValueHasAName       = $false
                        ValueName           = $ValueName
                        ValueUnescaped      = $UnescapedValue
                        ValueOriginal       = $CurrentValue
                    }

                    $ValuesList.Add($obj)
                }

                # Handle decoding of REG_MULTI_SZ (Multi String) and REG_EXPAND_SZ (Expandable String) #######
                ##############################################################################################

                elseif($StringType -eq 'REG_EXPAND_SZ' -or $StringType -eq 'REG_MULTI_SZ'){

                    $StringIsMultiNamedRegex = [regex]'(?m)^"(.*)"=hex\(7\):'
                    $StringIsMultiDefaultRegex = [regex]'(?m)^@=hex\(7\):'
                    $StringIsExpandNamedRegex = [regex]'(?m)^"(.*)"=hex\(2\):'
                    $StringIsExpandDefaultRegex = [regex]'(?m)^@=hex\(2\):'

                    $StringMultiNamed = $StringIsMultiNamedRegex.Match($CurrentValue)
                    $StringMultiDefault = $StringIsMultiDefaultRegex.Match($CurrentValue)

                    $StringExpandNamed = $StringIsExpandNamedRegex.Match($CurrentValue)
                    $StringExpandDefault = $StringIsExpandDefaultRegex.Match($CurrentValue)

                    if($StringMultiNamed.Success){
                        $CurrentValue = $StringIsMultiNamedRegex.Replace($CurrentValue, '')
                        $ValueName = $StringMultiNamed.Groups[1].Value
                        $ValueHasAName = $true
                        $ValueIsDefault = $false
                        $OriginalType = 'REG_MULTI_SZ (Multi String)'
                    }
                    elseif($StringMultiDefault.Success){
                        $CurrentValue = $StringIsMultiDefaultRegex.Replace($CurrentValue, '')
                        $ValueName = $null
                        $ValueHasAName = $false
                        $ValueIsDefault = $true
                        $OriginalType = 'REG_MULTI_SZ (Multi String)'
                    }
                    elseif($StringExpandNamed.Success){
                        $CurrentValue = $StringIsExpandNamedRegex.Replace($CurrentValue, '')
                        $ValueName = $StringExpandNamed.Groups[1].Value
                        $ValueHasAName = $true
                        $ValueIsDefault = $false
                        $OriginalType = 'REG_EXPAND_SZ (Expandable String)'
                    }
                    elseif($StringExpandDefault.Success){
                        $CurrentValue = $StringIsExpandDefaultRegex.Replace($CurrentValue, '')
                        $ValueName = $null
                        $ValueHasAName = $false
                        $ValueIsDefault = $true
                        $OriginalType = 'REG_EXPAND_SZ (Expandable String)'
                    }

                    $CurrentValue = $CurrentValue -replace '\\', '' -replace '(\s*)', ''
                    $ValueBytes = [System.Convert]::FromHexString($CurrentValue.Replace(',', ''))
                    $ValueUnescaped = [Text.Encoding]::Unicode.GetString($ValueBytes)

                    $obj = [PSCustomObject]@{
                        RegistryHive       = $RegistryHiveLong
                        RegistryHiveAbbv   = $RegistryHiveShort
                        RegistryKey        = $RegistryKeyHeader
                        OriginalType       = $OriginalType
                        ValueIsDefault     = $ValueIsDefault
                        ValueHasAName      = $ValueHasAName
                        ValueName          = $ValueName
                        ValueUnescaped     = $ValueUnescaped
                        ValueOriginalBytes = $ValueBytes
                    }

                    $ValuesList.Add($obj)
                }
            }

            $ValuesList

        }
    }
}


$Reg4X = @'
[HKEY_CURRENT_USER\SOFTWARE\Adobe\Adobe Substance 3D Designer\session\projectMRUList]
"project0"="D:/3D/Materials/Substance SBSAR/Concrete/filled_cement_wall.sbsar"
"project1"="D:/3D/Materials/Substance SBSAR/Concrete/abandoned_burned_concrete_wall.sbsar"
"project2"="D:/3D/Materials/Substance SBSAR/Concrete/concrete_wall_waterfall_pattern.sbsar"
"project3"="D:/3D/Materials/Adobe Substance SBS/Aged Scratched Metal/aged_scratched_metal.sbs"
"project4"="D:/3D/Materials/Adobe Substance/Concrete/stained_concrete_floor.sbsar"
"project5"="D:/3D/Materials/Adobe Substance/Concrete/concrete_sidewalk_patch_01.sbsar"
'@
$Reg1 = @'
@="\"%FM_BIN%\\hideexec.exe\" C:\\Program Files\\PowerShell\\7\\pwsh.exe -WindowStyle Hidden -RemoveWorkingDirectoryTrailingCharacter -WorkingDirectory \"%V!\" -Command \"Start-Process 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' -Verb runAS;Exit\""
'@

$Reg1b = @'
@="\"C:\\Program Files\\Git\\git-bash.exe\" \"--cd=%v.\""
'@

$Reg1c = @'
"project5"="\"C:\\Program Files\\Git\\git-bash.exe\" \"--cd=%v.\""
'@

$Reg2 = @'
[HKEY_CLASSES_ROOT\Drive\shell\c3_PowerShell7Admin\command]
@="\"%FM_BIN%\\hideexec.exe\" C:\\Program Files\\PowerShell\\7\\pwsh.exe -WindowStyle Hidden -RemoveWorkingDirectoryTrailingCharacter -WorkingDirectory \"%V!\" -Command \"Start-Process 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' -Verb runAS;Exit\""
'@

$Reg3 = @'
[HKEY_CURRENT_USER\SOFTWARE\Discord\Modules\discord_aegis]
"Path_x64"=hex(7):5c,00,5c,00,3f,00,5c,00,43,00,3a,00,5c,00,55,00,73,00,65,00,\
  72,00,73,00,5c,00,66,00,75,00,74,00,75,00,72,00,5c,00,41,00,70,00,70,00,44,\
  00,61,00,74,00,61,00,5c,00,4c,00,6f,00,63,00,61,00,6c,00,5c,00,44,00,69,00,\
  73,00,63,00,6f,00,72,00,64,00,5c,00,61,00,70,00,70,00,2d,00,31,00,2e,00,30,\
  00,2e,00,39,00,31,00,35,00,33,00,5c,00,6d,00,6f,00,64,00,75,00,6c,00,65,00,\
  73,00,5c,00,64,00,69,00,73,00,63,00,6f,00,72,00,64,00,5f,00,6d,00,6f,00,64,\
  00,75,00,6c,00,65,00,73,00,2d,00,31,00,5c,00,64,00,69,00,73,00,63,00,6f,00,\
  72,00,64,00,5f,00,6d,00,6f,00,64,00,75,00,6c,00,65,00,73,00,5c,00,63,00,30,\
  00,63,00,64,00,61,00,35,00,63,00,37,00,37,00,33,00,32,00,38,00,32,00,30,00,\
  5c,00,64,00,69,00,73,00,63,00,6f,00,72,00,64,00,5f,00,61,00,65,00,67,00,69,\
  00,73,00,5f,00,78,00,36,00,34,00,2e,00,64,00,6c,00,6c,00,00,00
'@

$Reg4 = @'
[HKEY_CLASSES_ROOT\SystemFileAssociations\.ico\Shell\a04_ConversionUtilities\Shell\a04_ConvertToPNGAll\command]
@=hex(7):22,00,25,00,46,00,4d,00,5f,00,42,00,49,00,4e,00,25,00,5c,00,53,00,69,\
  00,6e,00,67,00,6c,00,65,00,49,00,6e,00,73,00,74,00,61,00,6e,00,63,00,65,00,\
  41,00,63,00,63,00,75,00,6d,00,75,00,6c,00,61,00,74,00,6f,00,72,00,2e,00,65,\
  00,78,00,65,00,22,00,20,00,2d,00,74,00,3a,00,31,00,34,00,30,00,20,00,2d,00,\
  66,00,20,00,22,00,2d,00,63,00,3a,00,70,00,77,00,73,00,68,00,20,00,2d,00,6e,\
  00,6f,00,70,00,72,00,6f,00,66,00,69,00,6c,00,65,00,20,00,2d,00,6e,00,6f,00,\
  65,00,78,00,69,00,74,00,20,00,2d,00,43,00,6f,00,6d,00,6d,00,61,00,6e,00,64,\
  00,20,00,5c,00,22,00,26,00,20,00,27,00,25,00,46,00,4d,00,5f,00,50,00,53,00,\
  5f,00,57,00,52,00,41,00,50,00,50,00,45,00,52,00,53,00,25,00,5c,00,49,00,6d,\
  00,61,00,67,00,65,00,5c,00,49,00,6d,00,67,00,4f,00,70,00,73,00,2d,00,41,00,\
  30,00,32,00,2d,00,43,00,6f,00,6e,00,76,00,65,00,72,00,74,00,49,00,43,00,4f,\
  00,74,00,6f,00,50,00,4e,00,47,00,2e,00,70,00,73,00,31,00,27,00,20,00,2d,00,\
  46,00,69,00,6c,00,65,00,4c,00,69,00,73,00,74,00,20,00,24,00,66,00,69,00,6c,\
  00,65,00,73,00,20,00,5c,00,22,00,22,00,20,00,22,00,25,00,31,00,22,00,00,00
'@

ConvertTo-UnescapedRegistryStrings -String $Reg3