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

function Get-NVMNodeNPMVersions {

    [CmdletBinding()]
    param (
        [ValidateSet('Table','Json','List', IgnoreCase = $true, ErrorMessage="'{0}' is not a valid Output Format.")]
        [String] $OutputFormat='Table',
        [ValidateSet([NVMNodeVersions], ErrorMessage="'{0}' is not valid. That version of node is not installed or inaccessable to NVM.")]
        [Array] $SelectVersions = 'ALL',
        [Switch] $ShowHeader,
        [int32] $TableWidth,
        [Switch] $ClearHost
    )

    if($ClearHost){
        Clear-Host
    }
    $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
    $TableWidth = (-not($ConsoleWidth)) ? '80' : ($ConsoleWidth - 1)

    # Check if nvm (Node Version Manager) is installed
    try {
        try {
            $NvmCmd = Get-Command nvm.exe
        } catch {
            Write-Error "An error occured."
            throw $_
        }
    } catch {
        throw "Can't find nvm (Node Version Manager)"
    }


    # Get the root directory of Node.js versions managed by NVM
    [String]$NodeRoot = (& $NvmCmd root) -replace 'Current Root: ', ''
    $NodeRoot = $NodeRoot.Trim().TrimEnd("`r", "`n")

    # Store the root directories of each installed NodeJS Version
    $NodeVersionFolders = Get-ChildItem -Path $NodeRoot -Directory |
        Where-Object Name -Match '^v\d+\.\d+\.\d+$' |
        Select-Object -ExpandProperty FullName


    $VersionObj = [PSCustomObject]@{}

    foreach ($Dir in $NodeVersionFolders) {

        $NodeVersion = Split-Path -Path $Dir -Leaf
        if($NodeVersion.StartsWith('v0')){
            continue
        }
        if($SelectVersions -notcontains 'ALL'){
            if($SelectVersions -notcontains ($NodeVersion.TrimStart('v'))){
                continue
            }
        }

        # Initialize container variables to store the final formatted data
        [String]$ListPackagesString = ""
        [String]$TablePackagesString = ""
        [Array]$JSONPackagesArray = @()

        $NodeModulesFolder = Join-Path $Dir -ChildPath 'node_modules'
        $NPMPackageJSON = [System.IO.Path]::Combine($NodeModulesFolder, 'npm', 'package.json')
        $NPMPackageJSONObj = Get-Content $NPMPackageJSON | ConvertFrom-Json
        $NPMVersion = $NPMPackageJSONObj.version

        # Populate package container variables based on the output format
        if($OutputFormat -eq 'Table'){
            $TablePackagesString += "[#75B5AA]NPM@$NPMVersion[/]`n"
        }
        elseif($OutputFormat -eq 'JSON'){
            $JSONPackagesArray += "NPM@$NPMVersion"
        }
        elseif($OutputFormat -eq 'List'){
            $ListPackagesString += "NPM@$NPMVersion`n"
        }

        # Build the final output for the selected output format
        if($OutputFormat -eq 'Table'){
            $TablePackagesString = $TablePackagesString.Trim().TrimEnd("`r", "`n")
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
        $ListString = $ListString -replace '\r?\n', ''
        $ListString
    }
    elseif($OutputFormat -eq 'Table'){
        if($ShowHeader){
            Write-Host ''
            Write-SpectreHost -Message "[white] Current versions of NPM:[/]"
            Write-Host ''
        }
        Format-SpectreTable -Data $VersionObj -Border Rounded -Color "#63636a" -AllowMarkup -Width $TableWidth
        Write-Host ""
    }
    elseif($OutputFormat -eq 'JSON'){
        $VersionObj | ConvertTo-Json
    }
}