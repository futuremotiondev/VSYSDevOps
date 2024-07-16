using namespace System.Management.Automation
using namespace System.IO
class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
<#
.SYNOPSIS
A function to get the list of globally installed Node.js packages for specified or all installed versions.

.DESCRIPTION
The Get-NodeGlobalPackages function retrieves the globally installed Node.js packages. It can be used with specific version(s) of Node.js or for all installed versions if no particular version is specified.

.PARAMETER Versions
An array of strings representing the Node.js versions for which to retrieve globally installed packages. This parameter uses the NodeVersions validation set.

.PARAMETER Depth
A string that specifies the depth level for listing installed Node.js packages. The default value is '0', indicating that only top-level packages will be listed. Other possible values are from '1' to '5'.

.PARAMETER OutFile
A string representing the output filename where the list of globally installed packages will be stored. If this parameter is provided, the results won't be printed in the console but saved in the specified output file. Note: The OutFile and OutDir parameters cannot be used together.

.PARAMETER OutDir
A string representing the directory path where the list of globally installed packages will be stored for each version. If this parameter is provided, the results won't be printed in the console but saved in individual files in the specified directory. Note: The OutDir and OutFile parameters cannot be used together.

.EXAMPLE
Get-NodeGlobalPackages -Versions '14.15.1','12.18.3' -Depth '2'
This command will display the globally installed Node.js packages for versions '14.15.1' and '12.18.3', up to a package depth of 2.

.EXAMPLE
Get-NodeGlobalPackages -OutFile 'C:\temp\NodePackages.txt'
This command will save the list of globally installed Node.js packages for all installed versions (default behavior when no version is specified), into the 'C:\temp\NodePackages.txt' file.

.EXAMPLE
Get-NodeGlobalPackages -OutDir 'C:\temp\NodePackages'
This command will save the list of globally installed Node.js packages for all installed versions into individual files, located in the 'C:\temp\NodePackages' directory.

.NOTES
The function assumes that Node.js is installed via the Node Version Manager (NVM).
If both OutFile and OutDir parameters are provided, an error is thrown.
If a file already exists at the specified OutFile path, an error is thrown.
#>
function Get-NodeGlobalPackages {

    [CmdletBinding()]
    param(
        [ValidateSet([NodeVersions])]
        [String[]]$Versions,

        [ValidateSet('0','1','2','3','4','5')]
        [String] $Depth = '0',
        [String] $OutFile,
        [String] $OutDir
    )

    # Begin Parameter Validation
    if($OutFile -and $OutDir){
        throw "OutFile and OutDir cannot be used together."
    }
    if($OutFile){
        if(Test-Path $OutFile){
            throw "Outfile already exists. Specify a different output filename."
        }
    }

    # If no versions are passed, retrieve all of them.
    if(!$Versions){
        $VersionList = Get-InstalledNodeVersionsWithNVM -VersionOnly
    }else{
        $VersionList = $Versions
    }

    $ActiveVersion = Get-ActiveNodeVersionWithNVM

    if(!$OutFile -and !$OutDir){
        foreach ($v in $VersionList) {

            Write-SpectreHost "[white]Global packages for Node.js [/][#6A90FF]v$v[/]"
            Write-SpectreHost "[white]Package Depth is[/] [#8CA8E2]$Depth[/]`n"
            & nvm.exe use $v | Out-Null

            $NpmCmd = Get-Command npm.cmd
            $globalPackages = & $NpmCmd list -g --depth=$Depth

            foreach ($Package in $globalPackages) {
                if([String]::IsNullOrEmpty($Package)){
                    continue
                }
                Write-SpectreHost $Package
            }

            Write-Output "`n`n─────────────────────────────────────────────────────────────────`n`n"
        }

    }else{

        if($OutFile){
            New-Item -Path $OutFile -Force | Out-Null
        }

        function Write-ToFiles($text) {
            if($OutDir) { $text | Out-File $OutputFile -Append }
            if($OutFile) { $text | Out-File $OutFile -Append }
        }

        foreach ($v in $VersionList) {

            $OutputFile = if($OutDir) { Join-Path $OutDir "NodeJS-Packages-$v.txt" } else { $null }

            $Out1 = "Global packages for Node.js v$v"
            $Out2 = "Package Depth is $Depth`n"

            Write-ToFiles $Out1
            Write-ToFiles $Out2

            & nvm.exe use $v | Out-Null
            $NpmCmd = Get-Command npm.cmd
            $globalPackages = & $NpmCmd list -g --depth=$Depth

            foreach ($Package in $globalPackages) {
                if(-not [String]::IsNullOrEmpty($Package)){
                    Write-ToFiles $Package
                }
            }

            $OutSep = "`n`n─────────────────────────────────────────────────────────────────`n`n"
            Write-ToFiles $OutSep
        }
    }

    if(-not[String]::IsNullOrEmpty($ActiveVersion)){
        Write-SpectreHost "`n[white]Reactivating your previously active version ([/][#6A90FF]v$ActiveVersion[/])`n"
        & nvm use $ActiveVersion
    } else {
        Write-Warning "Couldn't determine your previously active NodeJS version."
    }
}