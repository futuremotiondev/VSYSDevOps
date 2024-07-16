using namespace System.Management.Automation
class NVMNodeVersions : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $lookup = @()
        $NvmCmd = Get-Command nvm.exe
        $Versions = & $NvmCmd list
        # Strip the asterisk and the text "(Currently using 64-bit executable)"
        $lookup = ($Versions -replace '\*|\(.*\)', '') -split "`r`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $lookup += "ALL"
        return $lookup
    }
}
<#
.SYNOPSIS
    Retrieves the global packages installed for each Node.js version managed by NVM (Node Version Manager).

.DESCRIPTION
    The Get-InstalledNodeGlobalPackages function retrieves the global packages installed for each Node.js version managed by NVM.
    The output can be displayed as a table, as a JSON string, or as a simple List.
    If the selected output format is a table, you can additionally specify the table width and whether to show a header above the table.

.PARAMETER TableWidth
    The width of the table if the OutputFormat is set to 'Table'. Default is the console width.

.PARAMETER ShowHeader
    Displays a header above the table if the OutputFormat is set to 'Table'.

.PARAMETER ClearScreen
    If this switch is provided, the screen will be cleared before output is displayed.

.PARAMETER IncludeOldBranches
    If set, old branches will be included in the output. (Node Versions v0.X.X)

.PARAMETER OutputFormat
    The output format. Options are 'Table', 'Json', and 'List'. Default is 'Table'.

.PARAMETER SelectVersions
    An array that narrows the output results to specific installed Node.js versions.
    If 'ALL' is passed, every node version will be outputted.

.AUTHOR
    Futuremotion
    https://www.github.com/fmotion1

.EXAMPLE
    Get-InstalledNodeGlobalPackages -OutputFormat 'List'

    This example retrieves the global packages installed for all Node.js versions and outputs the results in a list.

.EXAMPLE
    Get-InstalledNodeGlobalPackages -OutputFormat 'Table' -ShowHeader

    This example retrieves the global packages installed for all Node.js versions, shows the header, and outputs the results in a table.

.EXAMPLE
    Get-InstalledNodeGlobalPackages -OutputFormat 'Json' -ClearScreen

    This example clears the screen, retrieves the global packages installed for all Node.js versions, and outputs the results in JSON format.

.EXAMPLE
    Get-InstalledNodeGlobalPackages -OutputFormat 'Table' -SelectVersion '21.6.2', '20.11.1'

    This example retrieves the global packages installed for the Node.js versions 21.6.2 and 20.11.1, and outputs the results in a table.
#>
function Get-InstalledNodeGlobalPackages {

    [CmdletBinding()]
    param (
        [int32] $TableWidth,
        [Switch] $ShowHeader = $false,
        [Switch] $ClearScreen,
        [Switch] $IncludeOldBranches,

        [ValidateSet('Table','Json','List', IgnoreCase = $true, ErrorMessage="'{0}' is not a valid Output Format.")]
        [String] $OutputFormat='Table',

        [ValidateSet([NVMNodeVersions], ErrorMessage="'{0}' is not valid. That version of node is not installed or inaccessable to NVM.")]
        [Array] $SelectVersions = 'ALL'
    )

    if($ClearScreen){
        Clear-Host
    }

    # Set the table width based on the console width
    $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
    $TableWidth = (-not($ConsoleWidth)) ? '80' : ($ConsoleWidth - 1)

    # Check if nvm (Node Version Manager) is installed
    try {
        $NvmCmd = Get-Command nvm.exe
    } catch {
        throw "Can't find nvm (Node Version Manager)"
    }


    # Get the root directory of Node.js versions managed by NVM
    [String]$NodeRoot = (& $NvmCmd root) -replace 'Current Root: ', ''
    $NodeRoot = $NodeRoot.Trim().TrimEnd("`r", "`n")

    # Store the root directories of each installed NodeJS Version
    $NodeVersionFolders = Get-ChildItem -LiteralPath $NodeRoot -Directory |
        Where-Object Name -Match '^v\d+\.\d+\.\d+$' |
        Select-Object -ExpandProperty FullName

    # Initialize the PSCustomObject that will store version and package data for
    # Table and JSON output.
    $VersionObj = [PSCustomObject]@{}

    # Initialize the string that will store version and package data for list output.
    [String]$ListString = ""


    foreach ($Dir in $NodeVersionFolders) {

        # Get the directory of the global packages for the current Node.js version
        $NodeVersionModulesFolder = Join-Path $Dir -ChildPath "node_modules"
        $ModuleDirectories = Get-ChildItem -LiteralPath $NodeVersionModulesFolder -Directory
                           | Select-Object -ExpandProperty FullName

        # Create a formatted version string for each Node version
        $NodeVersion = Split-Path -Path $Dir -Leaf

        # Skip old branches if the IncludeOldBranches switch is not provided
        if(-not($IncludeOldBranches)){
            if($NodeVersion.StartsWith('v0')){
                continue
            }
        }

        # Skip versions not in the SelectVersions array
        if($SelectVersions -notcontains 'ALL'){
            if($SelectVersions -notcontains ($NodeVersion.TrimStart('v'))){
                continue
            }
        }

        # Initialize container variables to store the final formatted data
        [String]$ListPackagesString = ""
        [String]$TablePackagesString = ""
        [Array]$JSONPackagesArray = @()

        # Get the name and version of each global package for the current Node.js
        # version by retrieving the corresponding package.json files for each global
        # module.
        foreach ($ModuleDir in $ModuleDirectories) {
            $PackageJsonFile = Get-FirstUniqueFileByDepth -Directory $ModuleDir -FileName "package.json" -Depth 4
            if($null -eq $PackageJsonFile){
                Write-Warning "package.json was not found in $ModuleDir"
                continue
            }

            # Get the global module name and version
            $PackageJsonObj = Get-Content $PackageJsonFile | ConvertFrom-Json
            $ModuleName = $PackageJsonObj.name
            $ModuleVersion = $PackageJsonObj.version

            # Populate package container variables based on the output format
            if($OutputFormat -eq 'Table'){
                $TablePackagesString += "[#75B5AA]$ModuleName@$ModuleVersion[/]`n"
            }
            elseif($OutputFormat -eq 'JSON'){
                $JSONPackagesArray += "$ModuleName@$ModuleVersion"
            }
            elseif($OutputFormat -eq 'List'){
                $ListPackagesString += "$ModuleName@$ModuleVersion`n"
            }
        }

        # Build the final output for the selected output format
        if($OutputFormat -eq 'Table'){
            $TablePackagesString = $TablePackagesString.TrimEnd("`r", "`n")
            $VersionObj | Add-Member -NotePropertyName $NodeVersion -NotePropertyValue $TablePackagesString | Out-Null
        }
        elseif($OutputFormat -eq 'JSON'){
            $VersionObj | Add-Member -NotePropertyName $NodeVersion -NotePropertyValue $JSONPackagesArray | Out-Null
        }
        elseif($OutputFormat -eq 'List'){
            $ListString += "Node Version: $NodeVersion`n"
            $ListString += "─────────────────────────────`n"
            $ListString += "$ListPackagesString`n"
        }
    }

    # Finally, output the data based on the output format.
    if($OutputFormat -eq 'List'){
        $ListString = $ListString.TrimEnd("`r", "`n")
        $ListString
    }
    elseif($OutputFormat -eq 'Table'){
        if($ShowHeader){
            Write-Host ''
            Write-SpectreHost -Message "[white]Currently installed global packages:[/]"
            Write-Host ''
        }
        Format-SpectreTable -Data $VersionObj -Border Rounded -Color "#63636a" -AllowMarkup -Width $TableWidth
    }
    elseif($OutputFormat -eq 'JSON'){
        $VersionObj | ConvertTo-Json
    }
}
