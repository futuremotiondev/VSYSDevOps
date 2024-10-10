using namespace System.Management.Automation

class PythonVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        [String[]] $v = ($script:PythonInstalledVersionsCompleter).Version
        return $v
    }
}

function Install-PythonGlobalPackages {
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet([PythonVersions])]
        [String[]] $Versions,

        [Parameter(Mandatory, Position = 1)]
        [String[]] $Packages
    )

    $PYLauncherCMD = Get-Command py.exe -CommandType Application
    if(!$PYLauncherCMD) { throw "Py Launcher (py.exe) is not available in PATH." }

    $Versions | ForEach-Object {
        foreach ($Package in $Packages) {
            $Params = "-$_", '-m', 'pip', 'install', $Package.Trim()
            & $PYLauncherCMD $Params
        }
    }
}