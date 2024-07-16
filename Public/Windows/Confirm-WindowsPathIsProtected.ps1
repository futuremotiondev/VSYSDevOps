function Confirm-WindowsPathIsProtected {
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if ($_ -notmatch '[\?\*]') { $true } else {
                throw 'Wildcard characters are not acceptable with -LiteralPath'
            }
        })]
        [ValidateNotNullOrEmpty()]
        [Alias("Path")]
        [Alias('PSPath')]
        [Alias('InputPath')]
        [String[]] $LiteralPath
    )

    begin {

        # Get OS drive
        $SystemOSDrive = ((Get-CimInstance -ClassName CIM_OperatingSystem).SystemDrive)
        if ([String]::IsNullOrEmpty($SystemOSDrive)) {
            $SystemOSDrive = $env:SystemDrive
            if([String]::IsNullOrEmpty($SystemOSDrive)){
                throw "Could not determine the system drive."
            }
        }

        $UnsafeWindowsPathsList = [System.Collections.Generic.List[String]]@()
        $UnsafeWindowsPaths = [System.Collections.Generic.List[String]]@()

        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonDesktopDirectory))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonDocuments))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonMusic))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonPictures))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonVideos))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonPrograms))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonStartMenu))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonStartup))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonTemplates))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Credentials")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Crypto")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Protect")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Windows\Network Shortcuts")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Windows\Templates")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Windows\SystemCertificates")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData) + "\Microsoft\Windows\DeviceMetadataStore")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\LocalLow")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::MyMusic))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::MyPictures))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::MyVideos))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\Downloads")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonProgramFiles))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFilesX86))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonProgramFilesX86))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::Programs))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::StartMenu))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::Startup))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::Windows))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::System))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86))
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Local\Microsoft\Windows\RoamingTiles")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Local\Programs")
        $UnsafeWindowsPathsList.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile) + "\AppData\Local\Programs\Common")
        $UnsafeWindowsPathsList.Add($SystemOSDrive + "\Users\Public")
        $UnsafeWindowsPathsList.Add($SystemOSDrive + "\Users\Public\AccountPictures")
        $UnsafeWindowsPathsList.Add($SystemOSDrive + "\Users\Public\Libraries")
        $UnsafeWindowsPathsList.Add($SystemOSDrive + "\Users")
        $UnsafeWindowsPathsList.Add($SystemOSDrive + "\Users\Default")
        $UnsafeWindowsPathsList.Add($env:APPDATA)
        $UnsafeWindowsPathsList.Add($env:LOCALAPPDATA)
        $UnsafeWindowsPathsList.Add($env:OneDrive)
        $UnsafeWindowsPathsList.Add([Environment]::ProcessPath)
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath '$WinREAgent'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath '$Windows.~WS'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath '$WINDOWS.~BT'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Recovery'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'OneDriveTemp'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\AppData'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\Desktop'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\Documents'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\Downloads'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\Music'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\OneDrive'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\Pictures'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default\Videos'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Common Files'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Microsoft'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Microsoft'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\regid.1991-06.com.microsoft'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\USOPrivate'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\USOShared'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Packages'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\NVIDIA Corporation'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Package Cache'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Intel'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Microsoft Visual Studio'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Incredibuild'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\Windows App Certification Kit'))
        $UnsafeWindowsPathsList.Add((Join-Path -Path $SystemOSDrive -ChildPath 'ProgramData\$Recycle.Bin'))

        $UnsafeWindowsPathsListRecursive = [System.Collections.Generic.List[String]]@()
        $UnsafeWindowsPathsRecursive = [System.Collections.Generic.List[String]]@()

        $UnsafeWindowsPathsListRecursive.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::Windows))
        $UnsafeWindowsPathsListRecursive.Add([Environment]::GetFolderPath([Environment+SpecialFolder]::Fonts))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Default'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Users\Public'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\WindowsApps'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\dotnet'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Defender Advanced Threat Protection'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Microsoft Update Health Tools'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Defender'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Mail'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Multimedia Platform'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows NT'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Photo Viewer'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Portable Devices'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Security'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Sidebar'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Portable Devices'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Portable Devices'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Portable Devices'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Windows Portable Devices'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\WindowsPowerShell'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\PowerShell'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files\Internet Explorer'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\WindowsPowerShell'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows Sidebar'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows NT'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows Mail'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows Defender'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Microsoft.NET'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Internet Explorer'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows Portable Devices'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows Photo Viewer'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Windows Multimedia Platform'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\InstallShield Installation Information'))
        $UnsafeWindowsPathsListRecursive.Add((Join-Path -Path $SystemOSDrive -ChildPath 'Program Files (x86)\Reference Assemblies'))

        foreach ($Path in $UnsafeWindowsPathsList) {
            $UnsafeWindowsPaths.Add(([IO.Path]::TrimEndingDirectorySeparator($Path)).Trim())
        }

        foreach ($Path in $UnsafeWindowsPathsListRecursive) {
            $UnsafeWindowsPathsRecursive.Add(([IO.Path]::TrimEndingDirectorySeparator($Path)).Trim())
        }
    }

    process {

        $IsPathUnsafeAbsolute = {
            param (
                [Parameter(Mandatory)]
                [String] $Path
            )
            $Path = [IO.Path]::TrimEndingDirectorySeparator($Path).Trim()
            if($UnsafeWindowsPaths -contains $Path) { return $true }
            return $false
        }

        $IsPathUnsafeRecursive = {
            param (
                [Parameter(Mandatory)]
                [String] $Path
            )
            $Path = [IO.Path]::TrimEndingDirectorySeparator($Path).Trim()
            foreach ($UnsafePath in $UnsafeWindowsPathsRecursive) {
                if ($Path -like "$UnsafePath*") { return $true }
            }
            return $false
        }

        foreach ($InputPath in $LiteralPath) {
            $InputPath = [IO.Path]::TrimEndingDirectorySeparator($InputPath).Trim()
            if(& $IsPathUnsafeAbsolute -Path $InputPath) { Write-Output $true; continue }
            if(& $IsPathUnsafeRecursive -Path $InputPath) { Write-Output $true; continue }
            Write-Output $false
        }
    }

    end {}
}

