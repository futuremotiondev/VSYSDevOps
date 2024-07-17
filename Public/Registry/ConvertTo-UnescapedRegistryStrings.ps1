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