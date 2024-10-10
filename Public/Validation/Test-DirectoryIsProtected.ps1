<#
.SYNOPSIS
    Determines if a directory is protected by the operating system or user environment.

.DESCRIPTION
    This function checks if the provided directories are protected system directories or user environment directories. It returns a boolean value indicating whether each directory is protected.

.PARAMETER Directory
    The list of directories to check. Only directories will be accepted.

.EXAMPLE
    Test-DirectoryIsProtected -Directory "C:\Windows", "C:\Users\Public"

    This example checks if "C:\Windows" and "C:\Users\Public" are protected directories.

.NOTES
    Author: Futuremotion
    Date: 2023-10-10
    Website: https://github.com/futuremotiondev
#>
function Test-DirectoryIsProtected {

    [OutputType([bool])]
    [CmdletBinding()]

    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]] $Path
    )

    begin {

        $VAR_OS_DRIVE = ((Get-CimInstance -ClassName CIM_OperatingSystem).SystemDrive)
        if ([String]::IsNullOrEmpty($VAR_OS_DRIVE)) {
            $VAR_OS_DRIVE = $env:SystemDrive
            if([String]::IsNullOrEmpty($VAR_OS_DRIVE)){
                throw [System.IO.DriveNotFoundException] "Could not determine the system drive."
            }
        }
        $VAR_USER_HOME = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)

        $UNSAFE_STATIC = @{
            STATIC_USER_HOME    = $VAR_USER_HOME
            STATIC_USER_DESKTOP = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
            STATIC_USERS_DIR    = Join-Path $VAR_OS_DRIVE "Users"
        }

        $UNSAFE_RECURSIVE = @{
            RECURSE_SYS_WINDOWS_DIR        = [Environment]::GetFolderPath([Environment+SpecialFolder]::Windows)
            RECURSE_SYS_COMMON_FILES64     = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonProgramFiles)
            RECURSE_SYS_COMMON_FILES86     = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonProgramFilesX86)
            RECURSE_SYS_APPDATA            = Join-Path $VAR_USER_HOME 'AppData'
            RECURSE_SYS_PROGRAM_FILES86    = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFilesX86)
            RECURSE_SYS_PROGRAM_FILES64    = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
            RECURSE_SYS_PROGRAM_DATA       = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData)
            RECURSE_USER_PUBLIC_ROOT       = Join-Path $VAR_OS_DRIVE 'Users\Public'
            RECURSE_USER_DEFAULT_ROOT      = Join-Path $VAR_OS_DRIVE 'Users\Default'
            RECURSE_USER_HOME_NUGET        = Join-Path $VAR_USER_HOME '.nuget'
            RECURSE_USER_HOME_VSCODE       = Join-Path $VAR_USER_HOME '.vscode'
            RECURSE_USER_HOME_ECLIPSE      = Join-Path $VAR_USER_HOME '.eclipse'
            RECURSE_USER_HOME_DOTNET       = Join-Path $VAR_USER_HOME '.dotnet'
            RECURSE_USER_HOME_CONFIG       = Join-Path $VAR_USER_HOME '.config'
            RECURSE_OS_RECYCLEBIN          = Join-Path $VAR_OS_DRIVE '$Recycle.Bin'
            RECURSE_OS_WINDOWSBT           = Join-Path $VAR_OS_DRIVE '$WINDOWS.~BT'
            RECURSE_OS_WINDOWSWS           = Join-Path $VAR_OS_DRIVE '$Windows.~WS'
            RECURSE_OS_WINREAGENT          = Join-Path $VAR_OS_DRIVE '$WinREAgent'
            RECURSE_OS_RECOVERY            = Join-Path $VAR_OS_DRIVE 'Recovery'
            RECURSE_OS_SYS_VOLUME          = Join-Path $VAR_OS_DRIVE 'System Volume Information'
            RECURSE_OS_MINICONDA           = Join-Path $VAR_OS_DRIVE 'Python\miniconda3'
        }

        $VAR_OS_DRIVE_ESCAPED = [regex]::Escape($VAR_OS_DRIVE)
        $VAR_USER_HOME_ESCAPED = [regex]::Escape($VAR_USER_HOME)

        $UNSAFE_RECURSIVE_REGEX = @{
            RECURSE_REGEX_PYTHON1       = "$VAR_OS_DRIVE_ESCAPED\\Python\\Python[\d]{2,4}\\?$"
            RECURSE_REGEX_PYTHON2       = "$VAR_USER_HOME_ESCAPED\\Python[\d]{2,4}\\?$"
            RECURSE_REGEX_MINICONDA1    = "$VAR_OS_DRIVE_ESCAPED\\Python\\Miniconda[\d]{1,}\\?$"
            RECURSE_REGEX_MINICONDA2    = "$VAR_USER_HOME_ESCAPED\\Miniconda[\d]{1,}\\?$"
        }

        $UNSAFE_STATIC_PERSONAL = @{
            STATIC_BIN            = $env:FM_BIN
            STATIC_WRAPPERS       = $env:FM_PS_WRAPPERS
            STATIC_PYTHON_VENVS   = $env:FM_PY_VENV
            STATIC_TOOLS          = $env:FM_TOOLS
        }
    }

    process {
        :outer
        foreach ($Directory in $Path) {

            if(-not(Test-Path $Directory -PathType Container)){
                Write-Warning "Passed value is not a folder or doesn't exist."
                continue
            }

            $Directory = $Directory.TrimEnd('\')

            foreach ($UNSAFE_DIR in $UNSAFE_STATIC.GetEnumerator()) {
                if ($Directory -eq $UNSAFE_DIR.Value) { $true; continue outer}
            }
            foreach ($UNSAFE_DIR in $UNSAFE_STATIC_PERSONAL.GetEnumerator()) {
                if ($Directory -eq $UNSAFE_DIR.Value) { $true; continue outer}
            }
            foreach ($UNSAFE_DIR in $UNSAFE_RECURSIVE.GetEnumerator()) {
                if ($Directory -like "$($UNSAFE_DIR.Value)*") { $true; continue outer}
            }
            foreach ($UNSAFE_DIR in $UNSAFE_RECURSIVE_REGEX.GetEnumerator()) {
                if ($Directory -match $UNSAFE_DIR.Value) { $true; continue outer}
            }

            $Directory -match '^[a-zA-Z]:\\?(?:System Volume Information|\$RECYCLE\.BIN)?$'
        }
    }

    end {}
}