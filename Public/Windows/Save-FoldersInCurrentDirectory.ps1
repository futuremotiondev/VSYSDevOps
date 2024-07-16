function Save-FoldersInCurrentDirectory {

    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [ValidateNotNullOrEmpty()]
        [String] $Directory,
        [String[]] $FolderNames,
        [Switch] $Force
    )

    try {
        $Directory = [System.IO.Path]::GetFullPath($Directory)
    }
    catch {
        throw "Passed -Directory is not a valid path, or is malformed. ($Directory)"
    }

    $Exists = Test-Path -LiteralPath $Directory -PathType Container -ErrorAction SilentlyContinue
    if (-not $Exists) {
        if (-not $Force) {
            throw "The directory to create folders within doesn't exist. If you'd like to create it automatically, specify the -Force parameter."
        }
        else {
            if ($PSCmdlet.ShouldProcess("Directory: $Directory", "Create directory")) {
                $Directory = Get-UniqueFileOrFolderNameIfDuplicate -Path $Directory
                New-Item -Path $Directory -ItemType Directory -Force | Out-Null
            }
        }
    }

    foreach ($FolderName in $FolderNames) {

        $DestPath = Join-Path -Path $Directory -ChildPath $FolderName
        $DestPath = Get-UniqueFileOrFolderNameIfDuplicate -Path $DestPath

        if ($PSCmdlet.ShouldProcess("Folder: $DestPath", "Create folder")) {
            New-Item -Path $DestPath -ItemType Directory -Force | Out-Null
        }
    }

    Request-WindowsExplorerRefresh
}