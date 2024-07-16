function Get-PythonInstalledVersions {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory=$false, HelpMessage="Display only Paths")]
        [Parameter(Mandatory, ParameterSetName='PathOnly', HelpMessage="Display only Paths")]
        [switch] $PathOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only Versions")]
        [Parameter(Mandatory, ParameterSetName='VersionOnly', HelpMessage="Display only versions")]
        [switch] $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Filter results by major release version")]
        [ValidateSet('3','2','ALL', IgnoreCase = $true)]
        [String] $FilterVersion = 'ALL',

        [Parameter(Mandatory=$false, HelpMessage="Add a leading 'v' to the version strings")]
        [switch] $InsertLeadingV,

        [Switch] $ReverseResults,

        [Parameter(Mandatory=$false)]
        [Switch] $ShowTable

    )

    ## Parameter Validation
    if($PathOnly -and $VersionOnly){
        Write-Error "PathOnly and VersionOnly cannot be used together."
        return
    }

    ## Check if PY Launcher is available on the system PATH
    try {
        $PYLauncherCMD = Get-Command py.exe
    } catch {
        throw "Python Launcher (py.exe) isn't available in PATH."
    }

    # Initialize Variables to store Python Launcher results
    $PYLauncherCMD = Get-Command py.exe
    $pythonObjects = [System.Collections.Generic.List[Object]]@()
    $PY1 = (& $PYLauncherCMD -0) -split "\r?\n"
    $PY2 = (& $PYLauncherCMD -0p) -split "\r?\n"



    # Parser for Python Launcher results
    for ($idx = 0; $idx -lt $PY1.Count; $idx++) {

        $pyVersion = ''
        $pyLabel   = ''
        $pyArch    = ''
        $pyPath    = ''
        $pyBranch  = ''

        $line = $PY1[$idx] -replace '\* ', ''
        $parts = -split $line
        $archPat = '\((\d+)-bit\)'
        $archMatch = [System.Text.RegularExpressions.Regex]::Match($parts[3], $archPat)
        $pyVersion = $parts[0] -replace '\-V:',''
        $pyVersion = iex "$PYLauncherCMD -$pyVersion --version"

        $pyVersionMajor = ($pyVersion -split '\.')[0]
        if(($FilterVersion -eq '3') -and $pyVersionMajor -eq '2'){
            continue
        }
        elseif(($FilterVersion -eq '2') -and $pyVersionMajor -eq '3'){
            continue
        }

        if($pyVersion -like '3.*'){
            $pyBranch = 'CURRENT'
        }else{
            $pyBranch = 'OLD'
        }






        if($InsertLeadingV) { $pyVersion = "v"+$pyVersion }

        $pyLabel = ($parts[1] + ' ' + $parts[2] + ' ' + $parts[3]).Trim()
        $pyArch = ($archMatch.Success) ? $($archMatch.Groups[1].Value) : 'None'

        $line = $PY2[$idx] -replace '\* ', ''
        $parts = -split $line
        $finalPath = ''
        $pathIdx = 0
        $parts | ForEach-Object {
            if($pathIdx -ne 0) { $finalPath += $($_ + ' ') }
            $pathIdx++
        }
        $pyPath = $finalPath

        if($PathOnly){
            $Results = [PSCustomObject]@{
                Path    = $pyPath
            }
        }
        elseif($VersionOnly){
            $Results = [PSCustomObject]@{
                Version = $pyVersion
            }
        }
        else{
            $Results = [PSCustomObject]@{
                Label   = $pyLabel
                Version = $pyVersion
                Branch  = $pyBranch
                Path    = $pyPath
                Arch    = $pyArch
            }
        }
        $pythonObjects.Add($Results)
    }

    if($ReverseResults){
        $pythonObjects.Reverse()
    }

    if($PathOnly){
        if($ShowTable){
            Format-SpectreTable -Data $pythonObjects -Border Rounded -Color Grey37
        }else{
            $pythonObjects | ForEach-Object { $_.Path }
        }

    }
    elseif($VersionOnly){
        if($ShowTable){
            Format-SpectreTable -Data $pythonObjects -Border Rounded -Color Grey37
        }else{
            $pythonObjects | ForEach-Object { $_.Version }
        }
    }
    else{
        if($ShowTable){
            Format-SpectreTable -Data $pythonObjects -Border Rounded -Color Grey37
        }else{
            $pythonObjects
        }
    }
}