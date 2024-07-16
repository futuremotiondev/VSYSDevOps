
using namespace System.Management.Automation
class SpectreConsoleTableBorder : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = [Spectre.Console.TableBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
        return $lookup
    }
}
class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}

<#
    .SYNOPSIS
    This function returns the installed Node.js versions with Node Version Manager (NVM).

    .PARAMETER VersionOnly
    Optional switch to display only the version numbers of installed Node.js versions. If neither VersionOnly nor VersionAndPath are specified, default output will be used.

    .PARAMETER VersionAndPath
    Optional switch to display both the version numbers and installation paths of the installed Node.js versions.

    .PARAMETER FilterVersions
    Optional parameter specifying an array of specific versions to return, validated against installed Node.js versions.

    .PARAMETER Branch
    A string parameter to filter installations by branch. The accepted values are "CURRENT", "OLD", and "ALL". The default value is "ALL".

    .PARAMETER ShowBranch
    Optional switch that adds the branch column to the results if desired.

    .PARAMETER Table
    A switch parameter. When specified, the results will be formatted as a table for better readability.

    .PARAMETER TableBorder
    This parameter accepts a string representation of the desired style for the table border when displaying results in a table format.

    .EXAMPLE
    Get-InstalledNodeVersionsWithNVM -VersionAndPath -FilterVersions '12.18.3', '14.5.0' -Table

    This example retrieves the version and install path information for Node.js versions 12.18.3 and 14.5.0, and displays the results in a table format.
#>
function Get-InstalledNodeVersionsWithNVM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, HelpMessage="Display only versions.")]
        [switch] $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only versions and install paths.")]
        [switch] $VersionAndPath,

        [Parameter(HelpMessage="Return only specific versions.")]
        [ValidateSet([NodeVersions])]
        [string[]] $FilterVersions,

        [Parameter(HelpMessage="Display installations filtered by branch.")]
        [ValidateSet("CURRENT", "OLD", "ALL", IgnoreCase=$true)]
        [string] $Branch = "ALL",

        [Parameter(HelpMessage="Add the branch column to the results if desired.")]
        [switch] $ShowBranch,

        [Parameter(HelpMessage="Prettify the results with a table.")]
        [switch] $Table,

        [Parameter(HelpMessage="Change the style of the table border.")]
        [ValidateSet([SpectreConsoleTableBorder])]
        [String] $TableBorder = "Rounded"

    )

    process {
        # Ensure VersionOnly and VersionAndPath are not used together
        if ($VersionOnly -and $VersionAndPath) {
            throw "VersionOnly and VersionAndPath cannot be used together."
        }

        # Retrieves the command for executing NVM from the system.
        ## Check if NVM is available on the system PATH

        Write-Verbose "Checking if NVM is installed and available in PATH."

        try {
            $NVMCmd = Get-Command nvm -CommandType Application
        } catch {
            $ErrorText = "NVM Node Version Manager isn't installed or available in your PATH environment variable."
            $eRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
                'CommandNotFound',
                'CommandNotFound',
                $NVMCmd
            )
            Write-Error $eRecord
            return 2
        }

        Write-Verbose "NVM was found. Now attempting to invoke nvm root to retrieve output."

        $NVMRoot = (& $NVMCmd root)[1] -replace 'Current Root: '

        # Retrieve all child directories starting with 'v' from the
        # NVM installation root directory, trim off the 'v' at the
        # start, and store the array of full directory paths in the
        # NodeDirsFull variable.

        Write-Verbose "Retrieving all directories starting with 'v' from the NVM root directory"

        $NodeDirsFull = ((Get-ChildItem -Path $NVMRoot -Filter 'v*' -Directory).FullName).TrimStart('v')

        # Gets the list of installed Node.js versions using the "list"
        # command in NVM, splits the result by new lines, removes any
        # empty or null values, and stores the clean list in
        # NodeVersions.

        Write-Verbose "Retrieving and parsing a list of all installed Node.js versions via 'nvm list'."

        $NodeVersions = (& $NVMCmd list) | % { $_ -split '\r?\n'} | % { if(![String]::IsNullOrEmpty($_)){ $_ } }

        # cleans up the NodeVersions array by removing extra
        # characters such as '*', '(', ')', any text within
        # parentheses, and leading/trailing spaces.
        $NodeVersions = (($NodeVersions -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()

        # Full path directories corresponding to different Node.js versions installed on your system.
        $directoryString = $NodeDirsFull
        # A collection of strings representing different Node.js versions installed on your system via NVM.
        $versionString   = $NodeVersions

        # Split the strings into arrays
        $versions = $versionString -split "`n"
        $directories = $directoryString -split "`n"

        Write-Verbose "Creating a hashtable (map) to correlate Node versions with directories."

        # Create a hashtable to associate versions with directories
        $versionDirectoryMap = @{}

        try {
            foreach ($dir in $directories) {
                if($null -eq $dir){
                    throw "A directory parsed from 'nvm root' output evaluated to null."
                }
                if ($dir -match "v(\d+\.\d+\.\d+)$") {
                    $versionDirectoryMap[$Matches[1]] = $dir
                }
            }
        }
        catch {
            Write-Error "Error: $_"
        }

        Write-Verbose "The content of `$FilterVersions is: $FilterVersions"
        Write-Verbose "Selecting only the versions that the user requested."

        # Filter the versions if FilterVersions is specified
        if ($FilterVersions) {
            $versions = $versions | Where-Object { $_ -in $FilterVersions }
        }

        # The below is used to process and output a list of versioned
        # items based on certain parameters like branch, path, and
        # whether you want only the version or version and path.
        $output = @()
        foreach ($version in $versions) {
            $branchValue = if ($version.StartsWith("0")) { "OLD" } else { "CURRENT" }
            if ($Branch -eq "ALL" -or $Branch -eq $branchValue) {
                $path = $versionDirectoryMap[$version]

                $obj = [PSCustomObject]@{
                    Version = $version
                    Branch = $branchValue
                    Path = $path
                }

                if ($VersionOnly -and -not $Table) {
                    # Add only the version if VersionOnly is specified and not in table format
                    $output += $version
                } else {
                    # Adjust the object based on switches
                    if ($VersionAndPath) {
                        if ($ShowBranch) {
                            $output += [PSCustomObject]@{
                                Version = $version
                                Branch = $branchValue
                                Path = $path
                            }
                        } else {
                            $output += [PSCustomObject]@{
                                Version = $version
                                Path = $path
                            }
                        }
                    } else {
                        $output += $obj
                    }
                }
            }
        }

        # Below is responsible for arranging and formatting output
        # data to be displayed as a visual table in the terminal.
        # This operates when the -Table flag to be set.
        # PwshSpectreConsole is required for this to function.
        if ($Table) {
            if ($VersionOnly) {
                # Prepare data for Format-SpectreTable with only Version column
                $DataArr = $versions | ForEach-Object { [PSCustomObject]@{Version = $_} }
            } else {
                # Prepare data for Format-SpectreTable with all relevant columns
                $DataArr = @()
                foreach ($Property in $output) {
                    $tempObj = [PSCustomObject]@{}
                    foreach ($propName in $Property.PSObject.Properties.Name) {
                        if($propName -eq 'Version'){
                            $tempObj | Add-Member -Name $propName -Type NoteProperty -Value "[#8BA1FF]$($Property.$propName)[/]"
                        }else{
                            $tempObj | Add-Member -Name $propName -Type NoteProperty -Value $Property.$propName
                        }
                    }
                    $DataArr += $tempObj
                }
            }
            Format-SpectreTable -Data $DataArr -Border $TableBorder -Color Grey35 -AllowMarkup
        } elseif ($VersionOnly -and -not $Table) {
            # Return just the list of versions
            return $output
        } else {
            # Return the output as is
            return $output
        }
    }
}



