using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
function Update-NPMGlobalPackagesPerVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet([NodeVersions])]
        [String]
        $Version
    )

    process {
        $NVMCmd = Get-Command nvm.exe
        $Params = 'use', $Version
        & $NVMCmd $Params

        Write-SpectreHost -Message "About to update all global packages for [white]Node $Version[/]"
        Read-Host "Press any key to continue with the operation."
        $NPMCmd = Get-Command npm.cmd
        & $NPMCmd update -g
    }
}