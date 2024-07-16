using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
<#
    .SYNOPSIS
        This PowerShell function installs one or more Node.js packages globally for a specified Node.js version.

    .DESCRIPTION
        The Install-NodeGlobalPackages function uses the Node Version Manager (nvm) to switch to the desired Node.js version,
        then uses npm (Node Package Manager) to install the specified package(s) globally.
        If the -Prompt switch is present, it will confirm the action with the user before proceeding.

    .PARAMETER Version
        The version of Node.js where the packages will be installed.
        This parameter accepts node versions validated against the 'NodeVersions' set.

    .PARAMETER Packages
        An array of strings representing the package(s) to be installed.

    .PARAMETER Prompt
        A switch parameter. If present, the function will prompt the user for confirmation before installing the packages.

    .EXAMPLE
        Install-NodeGlobalPackages -Version "14.0.0" -Packages "express", "react" -Prompt

        This command will prompt the user for confirmation, then install the express and react packages globally under Node.js version 14.0.0.

    .NOTES
        URL: https://github.com/fmotion1
        Author: Futuremotion
        Date: 12-04-2023
#>
function Install-NodeGlobalPackages {
    param(
        [Parameter(Mandatory,Position=0)]
        [ValidateSet([NodeVersions])]
        $Version,
        [Parameter(Mandatory)]
        [String[]] $Packages,
        [Switch] $Prompt
    )

    if($Prompt){
        if($Packages.Count -gt 1){
            $PackagesList = $Packages -join ', '
        }
        $Plural = ($Packages.Count -gt 1) ? 'packages' : 'package'
        Write-SpectreHost "The $Plural [white]$PackagesList[/] will be installed in the following node version: [white]$Version[/]"
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

    $PackagesString = $Packages
    if($Packages.Count -gt 1){
        $PackagesString = $Packages -join ' '
    }

    Invoke-Expression "$NPMCmd install -g $PackagesString"
}