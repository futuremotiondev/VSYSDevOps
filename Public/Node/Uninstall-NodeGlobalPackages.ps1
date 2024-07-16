using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
<#
    .SYNOPSIS
        Uninstalls one or more Node.js global packages for a specific node version.

    .DESCRIPTION
        The Uninstall-NodeGlobalPackages function uninstalls specified Node.js global packages from the
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
        Uninstall-NodeGlobalPackages -Version "14.0.0" -Packages "package1", "package2", "package3"

    .EXAMPLE
        Uninstall-NodeGlobalPackages -Version "14.0.0" -Packages "package1" -Prompt

    .NOTES
        In order to use this function, nvm (Node Version Manager) and npm must be installed in your system.
#>
function Uninstall-NodeGlobalPackages {
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

    # Check if NVM is available
    try {
        $NVMCmd = Get-Command nvm.exe -CommandType Application
    } catch {
        Write-Error "Can't find nvm.exe (Node Version Manager)"
        throw $_
    }

    & $NVMCmd use $Version

    # Check if NPM is available
    try {
        $NPMCmd = Get-Command npm.cmd
    } catch {
        Write-Error "Can't find NPM (Is node installed correctly?)"
        throw $_
    }

    $PackagesString = $Packages -join ' '
    Invoke-Expression "$NPMCmd uninstall -g $PackagesString"
}