<#
.SYNOPSIS
    Retrieves the latest Node.js version installed with Node Version Manager (NVM).

.DESCRIPTION
    The Get-LatestNodeNVM function retrieves the latest Node.js version installed with Node Version Manager (NVM). 
    It calls the Get-InstalledNodeVersionsWithNVM function and returns the version of the first item in the returned list, which is the latest version.

.EXAMPLE
    Get-LatestNodeNVM

    This command retrieves the latest Node.js version installed with NVM.

.NOTES
    This function requires Node Version Manager (NVM) to be installed and properly configured. 
    It uses the Get-InstalledNodeVersionsWithNVM function, which should be defined in the same scope.
#>
function Get-LatestNodeWithNVM {
    [CmdletBinding()]
    param ()

    return (Get-InstalledNodeVersionsWithNVM)[0].Version
}