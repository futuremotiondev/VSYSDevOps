
function Get-ActiveNodeVersionWithNVM {
    <#
    .SYNOPSIS
        Gets the active Node.js version using Node Version Manager (NVM).

    .DESCRIPTION
        This function uses the 'nvm.exe list' command to get a list of installed Node.js versions.
        It then uses a regular expression to find the active version (indicated by a '*') in the list.

    .EXAMPLE
        PS C:\> Get-ActiveNodeVersionWithNVM

        This command returns the active Node.js version.

    .OUTPUTS
        System.String
        Returns the active Node.js version as a string.

    .NOTES
        This function requires NVM (Node Version Manager) to be installed and available via the command line.
    #>

    $VersionList = & nvm.exe list
    $activeVersion = [regex]::Match($VersionList, '\*\s*([0-9.]+)').Groups[1].Value
    $activeVersion
}