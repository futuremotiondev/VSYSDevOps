<#
.SYNOPSIS
    Splits the contents of directories into subfolders.

.DESCRIPTION
    The Split-DirectoryContentsToSubfolders function splits the contents of the specified directories into subfolders.
    The number of entries per subfolder can be specified. The function can process either files or folders.

.PARAMETER Directories
    Specifies the directories to process. This parameter accepts pipeline input and can be a string, or an object with a Path, FullName, or PSPath property.

.PARAMETER ProcessFolders
    If this switch is present, the function will process folders instead of files.

.PARAMETER NumEntriesPerFolder
    Specifies the number of entries per subfolder. The default is 1000.

.PARAMETER FolderNumberPadding
    Specifies the number of digits to use for the folder number. The default is 2.

.PARAMETER PathPrefix
    Specifies the prefix to use for the path. The default is 'None'. This parameter can be 'None' or 'FolderName'. If 'None' is passed, the folders do not get a prefix. If 'FolderName' is passed, the folders get a prefix consisting of their parent folder.

.EXAMPLE
    Split-DirectoryContentsToSubfolders -Directories "C:\Temp" -NumEntriesPerFolder 500

    This example splits the contents of the "C:\Temp" directory into subfolders, with 500 entries per subfolder.

.EXAMPLE
    Get-ChildItem -Path "C:\Temp" | Split-DirectoryContentsToSubfolders -NumEntriesPerFolder 200 -FolderNumberPadding 3

    This example gets the child items of the "C:\Temp" directory and passes them to the Split-DirectoryContentsToSubfolders function, which splits them into subfolders with 200 entries per subfolder and 3-digit folder numbers.

.EXAMPLE
    Split-DirectoryContentsToSubfolders -Directories "C:\Temp" -ProcessFolders -PathPrefix "FolderName"

    This example processes the folders in the "C:\Temp" directory and splits them into subfolders. The subfolders are named with the prefix of their parent folder.

.EXAMPLE
    Split-DirectoryContentsToSubfolders -Directories "C:\Temp" -PathPrefix "None"

    This example splits the contents of the "C:\Temp" directory into subfolders, with no prefix for the subfolders.

.AUTHOR
    Futuremotion
    https://www.github.com/fmotion1
#>
function Split-DirectoryContentsToSubfolders {

    [CmdletBinding(DefaultParameterSetName="Prefix")]

    param (
        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [Object[]] $Directories,

        [Switch] $ProcessFolders,
        [Int32] $NumEntriesPerFolder = 1000,
        [Int32] $FolderNumberPadding = 2,

        [parameter( ValueFromPipelineByPropertyName, ParameterSetName='Prefix' )]
        [ValidateSet('None','FolderName', IgnoreCase = $true)]
        [String] $PathPrefix = 'None'
    )

    begin {
        $List = [System.Collections.Generic.List[String]]@()
    }

    process {
        foreach ($P in $Directories) {
            $Path = if ($P -is [String])  { $P }
                    elseif ($P.Path)	  { $P.Path }
                    elseif ($P.FullName)  { $P.FullName }
                    elseif ($P.PSPath)	  { $P.PSPath }
                    else { Write-Error "$P is an unsupported type."; throw }

            # Resolve paths
            $ResolvedPaths = Resolve-Path -Path $Path
            foreach ($ResolvedPath in $ResolvedPaths) {
                if (Test-Path -Path $ResolvedPath.Path -PathType Container) {
                    $List.Add($ResolvedPath.Path)
                } else {
                    Write-Warning "$ResolvedPath does not exist on disk."
                }
            }
        }
    }

    end {

        foreach ($Dir in $List) {

            Set-Location -LiteralPath $Dir
            $DirObject = Get-Item -LiteralPath $Dir

            $CreateNewFolder = {
                $Prefix = if($PathPrefix -eq 'none') { '' }
                          else { $DirObject.BaseName }

                $NewChunk = $Index + 1
                $IndexFormatted = $NewChunk.ToString().PadLeft($FolderNumberPadding, '0')
                $FormatDirName = if(-not($ProcessFolders)) { "$Prefix $IndexFormatted".Trim() }
                          else { (Get-RandomAlphanumericString -Length 10) + "-$Prefix $IndexFormatted".Trim() }

                $OutputDirectory = [IO.Path]::Combine($DirObject.FullName, "$FormatDirName")
                [IO.Directory]::CreateDirectory($OutputDirectory).FullName
            }

            $Enumeration = if($ProcessFolders) { $DirObject.EnumerateDirectories() }
                           else { $DirObject.EnumerateFiles() }

            foreach ($Object in $Enumeration) {
                if($i++ % $NumEntriesPerFolder -eq 0) {
                    $NewFolder = (& $CreateNewFolder)
                    $Index++
                }
                $Dest = "$NewFolder\$($Object.Name)"
                [System.IO.Directory]::Move($Object.FullName, $Dest) | Out-Null
            }

            if($ProcessFolders) {
                Get-ChildItem -LiteralPath $DirObject -Directory | % {
                    $folderName = Split-Path -Path $_ -Leaf
                    $newFolderName = ($folderName -replace '^[^-]*-', '').TrimStart()
                    $parentPath = Split-Path -Path $_ -Parent
                    $newFolderPath = Join-Path -Path $parentPath -ChildPath $newFolderName
                    Rename-Item -Path $_ -NewName $newFolderPath -Force | Out-Null
                }
            }
        }
    }
}

