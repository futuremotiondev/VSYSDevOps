using namespace System.Management.Automation

class InstalledNVMNodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $InstalledNVMVersions = Get-NVMInstalledNodeVersions | % {$_.NPMVersion}
        $InstalledNVMVersions += 'All'
        return "'$InstalledNVMVersions'"
    }
}

function Get-NVMInstalledNPMVersions {

    param (
        [Parameter(ValueFromPipeline)]
        [ValidateSet([InstalledNVMNodeVersions])]
        [String] $NodeVersion = 'All'
    )

    $NodeVersions = Get-NVMInstalledNodeVersions
    $NPMObjects = [System.Collections.Generic.List[Object]]@()

    foreach ($Version in $NodeVersions) {
        if(($NodeVersion -ne $Version.Version) -and $NodeVersion -ne 'All'){
            continue
        }
        else {
            $NPMJson = [System.IO.Path]::Combine($Version.Path, 'node_modules', 'npm', 'package.json')
            Write-Host -f Green "`$NPMJson:" $NPMJson
            $NPMJsonContent = $NPMJson | ConvertFrom-Json -Depth 20
            $NPMVersion = $NPMJsonContent.version
            $NPMDocsHomepage = $NPMJsonContent.homepage
            $NPMGitHub = $NPMJsonContent.repository.url -replace '/cli/issues', ''
            $NPMSupportedVersions = $NPMJsonContent.engines.node
            $ActiveNodeVersion = Get-NVMActiveNodeVersion
            $IsActivated = ($Version.Version -eq $ActiveNodeVersion) ? $true : $false

            $OutputObject = [PSCustomObject]@{
                Label = "Node.js v$($Version.Version)"
                Version = $Version.Version
                NPMVersion = $NPMVersion
                NPMDocs = $NPMDocsHomepage
                NPMGitHub = $NPMGitHub
                SupportedNodeVersions = $NPMSupportedVersions
                NPMUpdateCommand = 'npm install -g npm@latest'
                NodeInstall = $Version.Path
                IsActivated = $IsActivated
            }

            $NPMObjects.Add($OutputObject)
        }

    }

    return $NPMObjects
}