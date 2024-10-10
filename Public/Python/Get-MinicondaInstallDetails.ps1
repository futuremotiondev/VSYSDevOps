<#
.SYNOPSIS
    Retrieves installation details for Miniconda.

.DESCRIPTION
    The Get-MinicondaInstallDetails function retrieves various details about a Miniconda installation,
    such as the installation path, version, and associated scripts. It searches for Miniconda installations
    in several common locations.

.PARAMETER Path
    Specifies the paths to process. This parameter accepts pipeline input and can be a string, or an object with a Path, FullName, or PSPath property.

.EXAMPLE
    Get-MinicondaInstallDetails

    This example retrieves details about the Miniconda installation in the current user's profile directory,
    or in the "C:\Miniconda3", "C:\Python\Miniconda3", or "C:\ProgramData\miniconda3" directories, if present.

.AUTHOR
    Futuremotion
    https://www.github.com/fmotion1
#>
function Get-MinicondaInstallDetails {

    [CmdletBinding()]
    param ()

    $MiniSearchPathA = "$env:USERPROFILE\Miniconda3"
    $MiniSearchPathB = "C:\Miniconda3"
    $MiniSearchPathC = "C:\Python\Miniconda3"
    $MiniSearchPathD = "C:\ProgramData\miniconda3"
    $MiniSearchPaths = @($MiniSearchPathA, $MiniSearchPathB, $MiniSearchPathC, $MiniSearchPathD)

    foreach ($Path in $MiniSearchPaths) {

        if (Test-Path $Path -PathType Container) {

            $Python = Join-Path $Path "python.exe"
            $PythonVersion = (& $Python --version) -replace 'Python ', ''

            $CondaExe = [System.IO.Path]::Combine($Path, "Scripts", "conda.exe")
            $CondaVersion = (& $CondaExe --version) -replace 'conda ', ''

            $ShellCondabin = Join-Path $Path -ChildPath 'shell' -AdditionalChildPath 'condabin'
            $ShellCondabinPwshModule = Join-Path $ShellCondabin -ChildPath 'Conda.psm1'
            $ShellCondaHookFile = Join-Path $ShellCondabin "conda-hook.ps1"
            $CondaUninstallExe = Join-Path $Path "Uninstall-Miniconda3.exe"

            $CondaExeCMD = Get-Command $CondaExe -CommandType Application
            $ShellCondabinPwshModuleArgsStr = (& $CondaExeCMD "shell.powershell" "hook") -split "`n"

            foreach ($line in $ShellCondabinPwshModuleArgsStr) {
                if ($line -match '\$CondaModuleArgs\s*=' ) {
                    $ShellCondabinPwshModuleArgs = $line.TrimStart('$CondaModuleArgs = ')
                }
                if ($line.Trim().StartsWith("Import-Module")) {
                    $ShellCondabinPwshHookExpression = $line
                }
                if ($line.Trim().StartsWith("Remove-Variable")) {
                    $ShellCondabinPwshHookExpression += "; $line"
                }
            }

            $PythonVersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Python)
            $PythonFileVersionRaw = $PythonVersionInfo.FileVersionRaw

            $Condabin = Join-Path $Path -ChildPath 'condabin'

            $CondabinScriptsList = [System.Collections.Generic.List[String]]@()
            $CondabinContents = Get-ChildItem -Path $Condabin
            foreach ($File in $CondabinContents) {
                $CondabinScriptsList.Add($File.FullName)
            }

            $CondaMetadataJSONDir = Join-Path $Path -ChildPath 'conda-meta'

            $CondaEnvsDir = Join-Path $Path -ChildPath 'envs'
            $CondaEnvs = Get-ChildItem -Path $CondaEnvsDir -Directory
            $CondaEnvsNum = $CondaEnvs.Length

            $CondaLibsDir = Join-Path $Path -ChildPath 'Lib'
            $CondaLibsInstalled = Get-ChildItem -Path $CondaLibsDir -Directory
            $CondaBinDir = Join-Path $Path -ChildPath 'bin'

            [PSCustomObject][Ordered]@{
                CondaRoot                       =  $Path
                CondaExe                        =  $CondaExe
                CondaVersion                    =  $CondaVersion
                ShellCondabin                   =  $ShellCondabin
                ShellCondabinHookFile           =  $ShellCondaHookFile
                ShellCondabinPwshModule         =  $ShellCondabinPwshModule
                ShellCondabinPwshHookArgs       =  $ShellCondabinPwshModuleArgs
                ShellCondabinPwshHookExpression =  $ShellCondabinPwshHookExpression
                CondabinRoot                    =  $Condabin
                CondabinScripts                 =  $CondabinScriptsList
                CondaMetadataJSONDir            =  $CondaMetadataJSONDir
                CondaEnvsDir                    =  $CondaEnvsDir
                CondaEnvsCount                  =  $CondaEnvsNum
                CondaEnvs                       =  $CondaEnvs
                CondaLibs                       =  $CondaLibsDir
                CondaLibsInstalled              =  $CondaLibsInstalled
                BinDirectory                    =  $CondaBinDir
                Python                          =  $Python
                PythonVersion                   =  $PythonVersion
                PythonVersionRaw                =  $PythonFileVersionRaw
                UninstallExe                    =  $CondaUninstallExe
            }
        }
    }
}

Get-MinicondaInstallDetails