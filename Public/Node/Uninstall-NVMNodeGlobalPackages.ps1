using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-NVMInstalledNodeVersions
        return $v
    }
}
<#
    .SYNOPSIS
        Uninstalls one or more Node.js global packages for a specific node version.

    .DESCRIPTION
        The Uninstall-NVMNodeGlobalPackages function uninstalls specified Node.js global packages from the
        given node version. The user can choose to be prompted for confirmation before each uninstallation.

    .PARAMETER Version
        Mandatory parameter. Specifies the version of Node.js from which the packages will be uninstalled.
        This parameter accepts node versions validated against the 'NodeVersions' set.

    .PARAMETER Packages
        Mandatory parameter. An array of strings specifying the names of the Node.js packages to be uninstalled.

    .PARAMETER Prompt
        Switch parameter. If this switch is provided, the function will prompt for confirmation before
        uninstalling the packages. The default is to not prompt.

    .EXAMPLE
        Uninstall-NVMNodeGlobalPackages -Version "14.0.0" -Packages "package1", "package2", "package3"

    .EXAMPLE
        Uninstall-NVMNodeGlobalPackages -Version "14.0.0" -Packages "package1" -Prompt

    .NOTES
        In order to use this function, nvm (Node Version Manager) and npm must be installed in your system.
#>
function Uninstall-NVMNodeGlobalPackages {
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateSet([NodeVersions])]
        $Version,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]
        $Packages,

        [Switch]$Prompt
    )

    if($Prompt){
        $PackagesList = $Packages -join ', '
        $Plural = ($Packages.Count -gt 1) ? 'packages' : 'package'
        Write-SpectreHost "The $Plural [white]$PackagesList[/] will be uninstalled in the following node version: [white]$Version[/]"
        $Result = Read-SpectreConfirm -Prompt "Do you want to continue?"
        if($Result -ne 'True') { exit }
    }

    $NVMCmd = Get-Command nvm.exe -CommandType Application -ErrorAction SilentlyContinue
    if(!$NVMCmd){
        throw "nvm.exe (Node Version Manager) can't be found. Make sure it's installed."
    }

    & $NVMCmd use $Version
    while (-not(Test-Path -LiteralPath "$env:NVM_SYMLINK")) {}

    $NPMCmd = Get-Command npm.cmd -CommandType Application -ErrorAction SilentlyContinue
    if(!$NPMCmd){
        $NPMCmd = Get-Command "$env:NVM_SYMLINK\npm.cmd" -CommandType Application -ErrorAction SilentlyContinue
        if(!$NPMCmd){
            throw "Can't find npm.cmd in PATH."
        }
    }

    $PackagesString = $Packages -join ' '
    Invoke-Expression "$NPMCmd uninstall -g $PackagesString"
}