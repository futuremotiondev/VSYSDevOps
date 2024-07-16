# REFACTOR: Cross platform
function Test-PathIsUnsafe {

    [CmdletBinding()]

    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]] $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Switch] $Strict,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Switch] $Detailed

    )

    begin {

        # Get OS drive
        $OSDrive = ((Get-CimInstance -ClassName CIM_OperatingSystem).SystemDrive)
        if ([String]::IsNullOrEmpty($OSDrive)) {
            $OSDrive = $env:SystemDrive
            if([String]::IsNullOrEmpty($OSDrive)){
                throw [System.IO.DriveNotFoundException] "Could not determine the system drive."
            }
        }

        $UnsafeDirStatic = @(
            [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonDesktopDirectory),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonDocuments),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonMusic),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonPictures),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonVideos),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonPrograms),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonStartMenu),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonStartup),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonTemplates),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Credentials",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Crypto",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Protect",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Windows\Network Shortcuts",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Windows\Templates",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Windows\SystemCertificates",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData) + "\Microsoft\Windows\DeviceMetadataStore",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\LocalLow",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::MyMusic),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::MyPictures),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::MyVideos),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\Downloads",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonProgramFiles),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFilesX86),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonProgramFilesX86),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::StartMenu),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::Windows),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::System),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86),
            $OSDrive + "\Users\Public",
            $OSDrive + "\Users\Public\AccountPictures",
            $OSDrive + "\Users\Public\Libraries",
            $OSDrive + "\Users",
            $OSDrive + "\Users\Default",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Local\Microsoft\Windows\RoamingTiles",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Local\Programs",
            [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Local\Programs\Common",
            $env:APPDATA,
            $env:LOCALAPPDATA,
            $env:OneDrive,
            [Environment]::ProcessPath,
            (Join-Path -Path $OSDrive -ChildPath '$WinREAgent'),
            (Join-Path -Path $OSDrive -ChildPath '$Windows.~WS'),
            (Join-Path -Path $OSDrive -ChildPath '$WINDOWS.~BT'),
            (Join-Path -Path $OSDrive -ChildPath 'Recovery'),
            (Join-Path -Path $OSDrive -ChildPath 'OneDriveTemp'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\AppData'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\Desktop'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\Documents'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\Downloads'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\Music'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\OneDrive'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\Pictures'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default\Videos'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Common Files'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Microsoft')
        )

        foreach ($Dir in $UnsafeDirStatic) {
            $Dir = [IO.Path]::TrimEndingDirectorySeparator($Dir)
        }

        $UnsafeDirRecursive = @(
            [Environment]::GetFolderPath([Environment+SpecialFolder]::Windows),
            [Environment]::GetFolderPath([Environment+SpecialFolder]::Fonts),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Default'),
            (Join-Path -Path $OSDrive -ChildPath 'Users\Public'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\WindowsApps'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\dotnet'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Defender Advanced Threat Protection'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Microsoft Update Health Tools'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Defender'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Mail'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Multimedia Platform'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows NT'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Photo Viewer'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Portable Devices'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Security'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Sidebar'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Portable Devices'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Portable Devices'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Portable Devices'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Windows Portable Devices'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\WindowsPowerShell'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\PowerShell'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files\Internet Explorer'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\WindowsPowerShell'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows Sidebar'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows NT'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows Mail'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows Defender'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Microsoft.NET'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Internet Explorer'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows Portable Devices'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows Photo Viewer'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Windows Multimedia Platform'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\InstallShield Installation Information'),
            (Join-Path -Path $OSDrive -ChildPath 'Program Files (x86)\Reference Assemblies'),
            [Environment]::ProcessPath
        )

        foreach ($Dir in $UnsafeDirRecursive) {
            $Dir = [IO.Path]::TrimEndingDirectorySeparator($Dir)
        }

        $UnsafeDirAnyDrive = @(
            'System Volume Information',
            '$RECYCLE.BIN'
        )

        $StrictUnsafeDirStatic = @(
            (Join-Path -Path $OSDrive -ChildPath 'Python27'),
            (Join-Path -Path $OSDrive -ChildPath 'Python38'),
            (Join-Path -Path $OSDrive -ChildPath 'Python310')
        )

        foreach ($Dir in $StrictUnsafeDirStatic) {
            $Dir = [IO.Path]::TrimEndingDirectorySeparator($Dir)
        }

        $StrictUnsafeDirRecursive = @(
            [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData),
            $env:APPDATA,
            $env:LOCALAPPDATA,
            [Environment]::ProcessPath
        )

        foreach ($Dir in $StrictUnsafeDirRecursive) {
            $Dir = [IO.Path]::TrimEndingDirectorySeparator($Dir)
        }
    }

    process {

        foreach ($SinglePath in $Path) {

            # Convert to backslash and limit consecutives
            $SinglePath = $SinglePath.Replace('/', '\')
            $SinglePath = $SinglePath -replace ('\\+', '\')
            $SinglePath = [IO.Path]::TrimEndingDirectorySeparator($SinglePath)

            $ValidationObject = [PSCustomObject]@{
                Path        = ''
                IsUnsafe    = $false
                Reason      = "Path is not sensitive."
            }

            foreach ($Dir in $UnsafeDirStatic) {
                if ($SinglePath -eq $Dir) {
                    $ValidationObject.Reason = "Path is a system critical directory. ($SinglePath)"
                    $ValidationObject.IsUnsafe = $true
                    $ValidationObject.Path   = $SinglePath
                }
            }

            if(!$ValidationObject.IsUnsafe){
                foreach ($Dir in $UnsafeDirRecursive) {
                    if ($SinglePath -like "$Dir*") {
                        $ValidationObject.Reason = "Path is within a system critical directory. ($SinglePath)"
                        $ValidationObject.IsUnsafe = $true
                        $ValidationObject.Path   = $SinglePath
                    }
                }
            }

            if(!$ValidationObject.IsUnsafe){
                foreach ($Dir in $UnsafeDirAnyDrive) {
                    $Escaped      = [Regex]::Escape($Dir)
                    $RegexOptions = [Text.RegularExpressions.RegexOptions]'IgnoreCase, CultureInvariant'
                    $RegEx        = "^[a-zA-Z]:\\$Escaped"
                    $Matched      = ([regex]::Match($SinglePath, $RegEx, $RegexOptions)).Success
                    $Matched      = [System.Convert]::ToBoolean($Matched)

                    if ($Matched) {
                        $ValidationObject.Reason = "Path is within a system critical directory. ($SinglePath)"
                        $ValidationObject.IsUnsafe = $true
                        $ValidationObject.Path   = $SinglePath
                    }
                }
            }

            if(!$ValidationObject.IsUnsafe){
                if (($SinglePath -match '^[a-zA-Z]:\\$') -or ($SinglePath -match '^[a-zA-Z]:$')) {
                    $ValidationObject.Reason = "Path is the root of a drive. ($SinglePath)"
                    $ValidationObject.IsUnsafe = $true
                    $ValidationObject.Path   = $SinglePath
                }
            }

            # Begin Strict Checks

            if ($Strict) {
                if(!$ValidationObject.IsUnsafe){
                    foreach ($Dir in $StrictUnsafeDirStatic) {
                        if ($SinglePath -eq $Dir) {
                            $ValidationObject.Reason = "Strict: Path is a possibly unsafe directory: $SinglePath"
                            $ValidationObject.IsUnsafe = $true
                            $ValidationObject.Path   = $SinglePath
                        }
                    }
                }

                if(!$ValidationObject.IsUnsafe){
                    foreach ($Dir in $StrictUnsafeDirRecursive) {
                        if ($SinglePath -like "$Dir*") {
                            $ValidationObject.Reason = "Strict: Path is within a possibly unsafe directory: $SinglePath"
                            $ValidationObject.IsUnsafe = $true
                            $ValidationObject.Path   = $SinglePath
                        }
                    }
                }
            }

            if(!$ValidationObject.IsUnsafe){
                Write-Verbose "$SinglePath is not a sensitive path."
                $ValidationObject.Reason = "Path is not a sensitive directory."
                $ValidationObject.IsUnsafe = $false
                $ValidationObject.Path   = $SinglePath
            }

            if($Detailed){
                $ValidationObject
            }else{
                $ValidationObject.IsUnsafe
            }

        }
    }

    end {}
}

# [string[]]$PathsToCheck = @(
#     'C:\',
#     'C:\Windows\System32\'
#     'C:\Windows\SysWOW64\'
#     'C:\Users\Username\Desktop\'
#     'C:\Users\futur\Desktop\'
#     'C:\ProgramData\'
#     'C:\Program Files (x86)\Adobe'
#     'C:\Program Files (x86)'
#     'C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies'
#     'C:\Program Files (x86)\icofx3\icofx3.exe'
# )

# Test-PathIsUnsafe 'C:\Windows\System32\'