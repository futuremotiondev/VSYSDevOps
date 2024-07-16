# REFACTOR: Cross-platform Linux / Windows Refactor
function Test-PathIsValid {
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'All')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'Leaf')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'Container')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'Relative')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'UNC')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName = 'Absolute')]
        [String[]]
        $Path,

        [Parameter(Mandatory = $false, ParameterSetName = 'Leaf')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Container')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Absolute')]
        [Parameter(Mandatory, ParameterSetName = 'UNC')]
        [switch]
        $UNC,

        [Parameter(Mandatory = $false, ParameterSetName = 'Leaf')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Container')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UNC')]
        [Parameter(Mandatory, ParameterSetName = 'Absolute')]
        [switch]
        $Absolute,

        [Parameter(Mandatory = $false, ParameterSetName = 'Leaf')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Container')]
        [Parameter(Mandatory, ParameterSetName = 'Relative')]
        [switch]
        $Relative,

        [Parameter(Mandatory, ParameterSetName = 'Container')]
        [switch]
        $Container,

        [Parameter(Mandatory, ParameterSetName = 'Leaf')]
        [switch]
        $Leaf,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'Leaf')]
        [string]
        $Extension
    )

    begin {

        $RegExOptions = [Text.RegularExpressions.RegexOptions]'IgnoreCase, CultureInvariant'
        $RegEx =
            '^'+
            # Drive
            '(?:(?:[a-z]:|\\\\[a-z0-9_.$●-]+\\[a-z0-9_.$●-]+)\\|' +
            # Relative Path
            '\\?[^\\\/:*?"<>|\r\n]+\\?)' +
            # Folder
            '(?:[^\\\/:*?"<>|\r\n]+\\)*' +
            #File
            '[^\\\/:*?"<>|\r\n]*' +
            '$'

        function SwitchValidation {
            param (
                [Parameter(Mandatory)]
                [String]
                $Testpath
            )

            $ext                = [IO.Path]::GetExtension($Testpath)
            $ext                = $ext.Replace('.','')
            $ExtensionArg       = $Extension.Replace('.','')
            $PathInfo           = [System.Uri]$Testpath
            $PathIsUNC          = $PathInfo.IsUnc
            $PathIsAbsolute     = [IO.Path]::IsPathRooted($Testpath)

            #$ext | Out-Host


            if(!(([regex]::Match($Testpath, $RegEx, $RegexOptions)).Success)){
                Write-Verbose "01: RegEx Match"
                return $false
            }

            if($Leaf -and ($ext -eq '')){
                Write-Verbose "02: Leaf Match"
                return $false
            }

            if($Extension -and ($ext -ne $ExtensionArg)){
                Write-Verbose "03: Extension Match"
                return $false
            }

            if($Container -and ($ext -ne '')){
                Write-Verbose "04: Folder Match"
                return $false
            }

            if($UNC -and (!$PathIsUNC)){
                Write-Verbose "05: UNC Match"
                return $false
            }

            if($Absolute -and (!$PathIsAbsolute)){
                Write-Verbose "06: Absolute Match"
                return $false
            }

            if($Relative -and $PathIsAbsolute){
                Write-Verbose "07: Relative Match"
                return $false
            }
            return $true
        }
    }

    process {
        foreach($p in $Path) {
            $ValidationObj = [PSCustomObject]@{
                Path    = $p
                Valid   = (SwitchValidation -Testpath $p)
            }
            $ValidationObj
        }
    }
}

# [string[]]$DummyPathSet = @(
#     "D:\VMs\Win10Sandbox\caches\GuestAppsCache\appData\ef7705b372eb14a0de0ad44feb0a69c0.appinfo"
#     "D:\ZBrush\Fibermesh\JHill Fibermesh Presets\"
#     "\\192.168.0.1\SHARE\my folder\"
#     "\\SERVER-01\Shared1\WGroups\Log-1.txt"
#     "..\..\bin\my_executable.exe"
#     "C:\Program Files\7-Zip\7z.exe"
#     "C:\Music\Full Circle\Track01.mp3"
# )

# Test-PathIsValid -Path $DummyPathSet -Container


