using namespace System.Management.Automation

function Get-InstalledNodeVersionsWithNVM {

    if(-not($env:NVM_HOME)){ return $null }
    $NVMCmd = Get-Command nvm -ErrorAction SilentlyContinue
    if(-not($NVMCmd)){ return $null }

    $NVMOutput = & $NVMCmd list
    $Arr = ($NVMOutput -split "\r?\n")
    $NodeVersions = foreach ($Item in $Arr) {
        if([String]::IsNullOrEmpty($Item)){ continue }
        (($Item -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()
    }

    foreach ($Version in $NodeVersions) {
        $Path = Join-Path $env:NVM_HOME -ChildPath "v$Version"
        if(-not(Test-Path $Path -PathType Container)){ continue }
        [PSCustomObject]@{
            Version = $Version
            Path = $Path
        }
    }
}