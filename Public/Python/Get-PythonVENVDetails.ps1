using namespace System.Text.RegularExpressions
function Get-PythonVENVDetails {
    [CmdletBinding()]
    [OutputType([VSYSDevOps.Python.PythonVENVObject])]
    param (
        [Parameter(Mandatory)]
        [String] $Folder

    )

    process {

        if(-not(Test-Path -LiteralPath $Folder -PathType Container)){
            throw "Folder doesn't exist. Check your spelling and try again."
        }

        if(-not(Confirm-PythonFolderIsVENV -Folder $Folder)){
            throw "Passed -Folder ($Folder) is not a Python VENV"
        }

        $VENVOriginalPython = "Not Found"
        $VENVIncludeSystemPackages = "Not Found"
        $VENVPythonVersion = "Not Found"

        try {

            Push-Location $Folder -StackName VENV

            $PythonVenvCfg = [System.IO.Path]::Combine($Folder, 'pyvenv.cfg')
            $DirectoryIsVENV = Test-Path -LiteralPath $PythonVenvCfg -PathType Leaf
            if(!$DirectoryIsVENV){
                Write-Error "The directory specified is not a Python VENV. (Missing pyvenv.cfg)"
                return
            }

            $PythonVenvFolder = $Folder

            $PythonActivatePS1 = [System.IO.Path]::Combine($Folder, 'Scripts', 'Activate.ps1')
            if(-not($PythonActivatePS1 | Test-Path)){
                $PythonActivatePS1 = "Not Found"
            }

            $PythonActivateBAT = [System.IO.Path]::Combine($Folder, 'Scripts', 'activate.bat')
            if(-not($PythonActivateBAT | Test-Path)){
                $PythonActivateBAT = "Not Found"
            }

            $PythonDeactivateBAT = [System.IO.Path]::Combine($Folder, 'Scripts', 'deactivate.bat')
            if(-not($PythonDeactivateBAT | Test-Path)){
                $PythonDeactivateBAT = "Not Found"
            }

            & $PythonActivatePS1

            $PipCmdPath = Join-Path -Path (Join-Path $PythonVenvFolder -ChildPath 'Scripts') -ChildPath 'pip.exe'
            $PipCmd = Get-Command $PipCmdPath -CommandType Application
            $PackageList = & $PipCmd list

            $PackageContainer = [System.Collections.Generic.List[psobject]]@()

            # Split the string into lines, skip the first two lines (header and separator), and process each package line
            $PackageList -split "`n" | Select-Object -Skip 2 | ForEach-Object {
                # Trim and split each line by spaces, filtering out empty elements resulting from multiple spaces
                $parts = $_.Trim() -split '\s+' | Where-Object { $_ -ne '' }

                # The first part is the package name, the rest (if there are version parts) join together as the version
                $packageName = $parts[0]
                $packageVersion = $parts[1]

                # Create and output a PSObject for each package
                $obj = [pscustomobject]@{
                    Package = $packageName
                    Version = $packageVersion
                }
                $PackageContainer.Add($obj)
            }

            $PythonExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'python.exe')
            if(-not($PythonExe | Test-Path)){
                $PythonExe = "Not Found"
            }

            $PythonDebugExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'python_d.exe')
            if(-not($PythonDebugExe | Test-Path)){
                $PythonDebugExe = "Not Found"
            }

            $PythonSitePKG = [System.IO.Path]::Combine($Folder, 'Lib', 'site-packages')
            if(-not($PythonSitePKG | Test-Path)){
                $PythonSitePKG = "Not Found"
            }

            $PythonPipExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'pip.exe')
            if(-not($PythonPipExe | Test-Path)){
                $PythonPipExe = "Not Found"
            }

            $PipCmd = Get-Command $PythonPipExe -CommandType Application
            $PythonPipVersion = "Unknown"
            $PipParams = "--version"
            $PipVersionString = & $PipCmd $PipParams

            $VersionRegex = '\b\d+(\.\d+)*(\w?\d*)?\b'
            $VersionMatch = [regex]::Match($PipVersionString, $VersionRegex)
            if ($VersionMatch.Success) {
                $PythonPipVersion = $VersionMatch.Value
            }

            $PythonConfigLines = Get-Content -Path $PythonVenvCfg
            foreach ($Line in $PythonConfigLines) {
                if ($Line -match '^home\s*=\s*(.*)') {
                    $VENVOriginalPython = $matches[1].Trim()
                } elseif ($Line -match '^version\s*=\s*(.*)') {
                    $VENVPythonVersion = $matches[1].Trim()
                } elseif ($Line -match '^include-system-site-packages\s*=\s*(.*)') {
                    $VENVIncludeSystemPackages = $matches[1].Trim()
                }
            }

            $ScriptsContents = Join-Path $Folder -ChildPath "Scripts"
            $PythonScriptsContents = Get-ChildItem $ScriptsContents
            if(-not($PythonScriptsContents)){
                Write-Error "Python Scripts folder is Empty."
                $PythonScriptsContents = @("Error: Not Found")
            }

            & deactivate

            Pop-Location -StackName VENV

            [VSYSDevOps.Python.PythonVENVObject]@{
                IsVENV                  = $DirectoryIsVENV
                VENVPath                = $PythonVenvFolder
                PythonVersion           = $VENVPythonVersion
                PythonHome              = $VENVOriginalPython
                ActivateFilePS1         = $PythonActivatePS1
                ActivateFileBAT         = $PythonActivateBAT
                DeactivateBAT           = $PythonDeactivateBAT
                SitePackagesDir         = $PythonSitePKG
                SitePackagesList        = $PackageContainer
                PythonBinary            = $PythonExe
                PythonDebugBinary       = $PythonDebugExe
                PIPBinary               = $PythonPipExe
                PIPVersion              = $PythonPipVersion
                IncludeSystemPackages   = $VENVIncludeSystemPackages
                ConfigFile              = $PythonVenvCfg
                ScriptsContent          = $PythonScriptsContents
            }

        } catch {
            & $PythonDeactivateBAT
            $PSCmdlet.ThrowTerminatingError($PSItem)

        }
    }
}