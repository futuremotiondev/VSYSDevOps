using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-NVMInstalledNodeVersions
        return $v
    }
}

function Install-NodeGlobalPackages {
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateSet([NodeVersions])]
        [String] $Version,
        [Parameter(Mandatory)]
        [String[]] $Packages,
        [Switch] $Prompt,
        [Switch] $SwitchBack
    )

    if($Prompt){
        if($Packages.Count -gt 1){ $PackagesList = $Packages -join ', ' }
        $Plural = ($Packages.Count -gt 1) ? 'packages' : 'package'
        Write-SpectreHost "The $Plural [white]$PackagesList[/] will be installed in the following node version: [white]$Version[/]"
        $Result = Read-SpectreConfirm -Prompt "Do you want to continue?"
        if($Result -ne 'True') { exit }
    }

    if($SwitchBack){
        $CurrentActiveVersion = Get-NVMActiveNodeVersion
    }

    $NVMCmd = Get-NVMCommand -ErrorAction Stop
    $NPMCmd = Get-NPMCommand -ErrorAction Stop

    Write-SpectreHost "Switching to Node Version v$Version"
    & $NVMCmd use $Version
    while (-not(Test-Path -LiteralPath "$env:NVM_SYMLINK")) {}

    $PackagesString = $Packages
    if($Packages.Count -gt 1){
        $PackagesString = $Packages -join ' '
    }
    else{
        $PackagesString = $PackagesString.Trim()
    }

    Invoke-Expression "$NPMCmd install -g $PackagesString"

    if($SwitchBack){
        Write-SpectreHost "Switching back to your previously activated version of Node ($CurrentActiveVersion)"
        & $NVMCmd use $CurrentActiveVersion
        while (-not(Test-Path -LiteralPath "$env:NVM_SYMLINK")) {}
    }
}

