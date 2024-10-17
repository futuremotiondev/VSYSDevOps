function Get-NVMInstalledNodeVersions {

    param (
        [switch] $Details
    )

    $NVMCmd = Get-NVMCommand -ErrorAction Stop

    $NVMOutput = & $NVMCmd 'list'
    $Arr = ($NVMOutput -split "\r?\n")
    $NodeVersions = foreach ($Item in $Arr) {
        if([String]::IsNullOrEmpty($Item)){ continue }
        (($Item -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()
    }

    if(!$Details){
        $NodeVersions
    }
    else {

        foreach ($Version in $NodeVersions) {

            $Path = Join-Path $env:NVM_HOME -ChildPath "v$Version"
            $NPMJson = Get-Content -Raw $([System.IO.Path]::Combine($Path, 'node_modules', 'npm', 'package.json')) | ConvertFrom-JSON
            $NPMVersion = $NPMJson.version
            $MajorVersion = ($Version -split '\.')[0]
            $DocsURL = "https://nodejs.org/dist/v{0}/docs/api/" -f $Version
            $ChangelogURL = "https://github.com/nodejs/node/blob/main/doc/changelogs/CHANGELOG_V{0}.md#{1}" -f $MajorVersion, $Version
            $DownloadURL = "https://nodejs.org/dist/v{0}/node-v{0}-x64.msi" -f $Version

            # Get the directory of the global packages for the current Node.js version
            $NodeModulesFolder = Join-Path $Path -ChildPath "node_modules"
            $ModuleDirectories = Get-ChildItem -LiteralPath $NodeModulesFolder -Directory -Depth 0 | % {$_.FullName}

            $GlobalModuleList = [System.Collections.Generic.List[Object]]@()

            foreach ($ModuleDir in $ModuleDirectories) {
                $Scoped = $false
                $Dirname = [System.IO.Path]::GetFileName($ModuleDir)
                if($Dirname.StartsWith('@')){
                    $ModuleDir = Get-ChildItem -LiteralPath $ModuleDir -Directory -Depth 0 | % {$_.FullName}
                    $Scoped = $true
                }
                $JSONFile = Get-ChildItem -LiteralPath $ModuleDir -Include 'package.json' | % {$_.FullName}
                $JSONData = Get-Content $JSONFile | ConvertFrom-Json
                $ModuleName = $JSONData.name
                $ModuleVersion = $JSONData.version
                $FormattedModule = "$ModuleName@$ModuleVersion"
                $url = "https://www.npmjs.com/package/$ModuleName"


                $o = [PSCustomObject]@{
                    ModuleName = $ModuleName
                    ModuleVersion = $ModuleVersion
                    ModuleID = $FormattedModule
                    ModuleLink = $url
                }

                $GlobalModuleList.Add($o)
            }

            [PSCustomObject]@{
                Label = "Node v$Version"
                Version = $Version
                DocsURL = $DocsURL
                ChangelogURL = $ChangelogURL
                DownloadURL = $DownloadURL
                Path = $Path
                GlobalModules = $GlobalModuleList
                NPMVersion = $NPMVersion
            }
        }
    }
}