using namespace System.Management.Automation
class NVMNodeVersions : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Versions = Get-NVMInstalledNodeVersions
        $Versions += 'All'
        return $Versions
    }
}

function Get-NVMNodeNPMVersions {

    [CmdletBinding()]
    param (

        [ValidateSet([NVMNodeVersions])]
        [String[]] $Version = 'ALL',

        [ValidateSet('Table','Json','List', IgnoreCase = $true, ErrorMessage="'{0}' is not a valid Output Format.")]
        [String] $OutputFormat='Table',

        [Switch] $ShowTableHeader,
        [int32] $TableWidth,
        [Switch] $ClearHost
    )

    if($ClearHost){ Clear-Host }


    $NvmCmd = Get-NVMCommand -ErrorAction Stop
    $NodeRoot = Get-NVMInstallationDirectory
    $InstalledNVMVersions = Get-NVMInstalledNodeVersions -Details
    $NVMVersionFolders = ($InstalledNVMVersions).Path

    $FinalReturnObject = [PSCustomObject]@{}
    $ObjectList = [System.Collections.Generic.List[Object]]@()

    foreach ($Version in $InstalledNVMVersions) {

        $NodeVersion = $Version.Version
        $NPMPackageJSON = [System.IO.Path]::Combine($($Version.Path), 'node_modules', 'npm', 'package.json')
        $NPMPackageJSONObj = Get-Content $NPMPackageJSON | ConvertFrom-Json
        $NPMVersion = $NPMPackageJSONObj.version

        [PSCustomObject]@{
            Label = "Node v$NodeVersion"
            NodeVersion = $NodeVersion
            NPMVersion = $NPMVersion

        }



        # if($OutputFormat -eq 'Table'){
        #     $TablePackagesString += "[#75B5AA]NPM@$NPMVersion[/]`n"
        # }
        # elseif($OutputFormat -eq 'JSON'){
        #     $JSONPackagesArray += "NPM@$NPMVersion"
        # }
        # elseif($OutputFormat -eq 'List'){
        #     $ListPackagesString += "NPM@$NPMVersion`n"
        # }

        # # Build the final output for the selected output format
        # if($OutputFormat -eq 'Table'){
        #     $TablePackagesString = $TablePackagesString.Trim().TrimEnd("`r", "`n")
        #     $FinalReturnObject | Add-Member -NotePropertyName $NodeVersion -NotePropertyValue $TablePackagesString | Out-Null
        # }
        # elseif($OutputFormat -eq 'JSON'){
        #     $FinalReturnObject | Add-Member -NotePropertyName $NodeVersion -NotePropertyValue $JSONPackagesArray | Out-Null
        # }
        # elseif($OutputFormat -eq 'List'){
        #     $ListString += "Node Version: $NodeVersion`n"
        #     $ListString += "─────────────────────────────`n"
        #     $ListString += "$ListPackagesString`n"
        # }
    }



    # Finally, output the data based on the output format.
    # if($OutputFormat -eq 'List'){
    #     $ListString = $ListString -replace '\r?\n', ''
    #     $ListString
    # }
    # elseif($OutputFormat -eq 'Table'){

    #     $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
    #     $TableWidth = (-not($ConsoleWidth)) ? '80' : ($ConsoleWidth - 1)

    #     if($ShowTableHeader){
    #         Write-Host ''
    #         Write-SpectreHost -Message "[white] Current versions of NPM:[/]"
    #         Write-Host ''
    #     }

    #     Format-SpectreTable -Data $FinalReturnObject -Border Rounded -Color "#63636a" -AllowMarkup -Width $TableWidth -
    #     Write-Host ""
    # }
    # elseif($OutputFormat -eq 'JSON'){
    #     $FinalReturnObject | ConvertTo-Json
    # }
}

# Get-NVMNodeNPMVersions