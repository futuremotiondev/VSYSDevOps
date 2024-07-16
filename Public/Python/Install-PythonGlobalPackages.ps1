using namespace System.Management.Automation

class PythonVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-PythonInstalledVersions -VersionOnly
        return $v
    }
}

function Install-PythonGlobalPackages {
    param(
        [Parameter(Mandatory)]
        [ValidateSet([PythonVersions])]
        $Version,

        [Parameter(Mandatory=$false)]
        [Switch]
        $Prompt,

        [Parameter(Mandatory,ValueFromRemainingArguments)]
        [String[]]
        $Packages

    )

    if($Prompt){
        $PackagesList = $Packages
        $Plural = 'package'
        if($Packages.Count -gt 1){
            $Plural = 'packages'
            $PackagesList = $Packages -join ', '
        }
        Write-SpectreHost "The $Plural [white]$PackagesList[/] will be installed in the following Python version: [white]$Version[/]"
        $Result = Read-SpectreConfirm "Do you want to continue?" -DefaultAnswer n
        if(!$Result) { exit }
    }

    $PYCmd = Get-Command py.exe

    foreach ($Package in $Packages) {
        $Params = "-$Version", '-m', 'pip', 'install', $Package.Trim()
        & $PYCmd $Params
    }
}