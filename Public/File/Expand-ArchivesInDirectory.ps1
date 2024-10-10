<#
.SYNOPSIS
    Recursively extracts archives from specified directories and optionally deletes them post-extraction.

.DESCRIPTION
    The Expand-ArchivesInDirectory function searches for various archive files within the given
    directories, extracts them using 7-Zip, and can delete the original archives if desired. It supports
    multiple archive formats and allows customization of extraction locations and duplicate file handling.

.PARAMETER LiteralPath
    Specifies one or more root directories to start the recursive search for archives.

.PARAMETER ExtractLocation
    Determines where the extracted files will be placed. Options are 'SameFolder' or 'Subfolder'.
    'SameFolder' extracts all files to the same folder as the archive.
    'Subfolder' extracts all files to a subfolder with the same name as the archive.

.PARAMETER DeleteArchives
    If specified, the original archives will be deleted after successful extraction.

.PARAMETER AutoRenameDuplicates
    If specified, automatically renames duplicate files during extraction to the same folder.

.PARAMETER MaxThreads
    Specifies the maximum number of threads to use for parallel processing. Defaults to 16.

.EXAMPLE
    Expand-ArchivesInDirectory -LiteralPath "C:\User\Downloads" -DeleteArchives

    Extracts all archives found in "C:\User\Downloads" and its subdirectories, then deletes the original
    archives after successful extraction.

.EXAMPLE
    Expand-ArchivesInDirectory -LiteralPath "D:\Data", "E:\BackupArchives" -ExtractLocation SameFolder -AutoRenameDuplicates

    Extracts archives found in both "D:\Data" and "E:\BackupArchives" into their respective folders,
    automatically renaming any duplicate files.

.EXAMPLE
    Expand-ArchivesInDirectory -LiteralPath "F:\Projects" -MaxThreads 8

    Extracts all archives found in "F:\Projects" using up to 8 threads for parallel processing.

.NOTES
    Author: Futuremotion
    Date: 10-03-2024
    URL: https://github.com/futuremotiondev
#>
function Expand-ArchivesInDirectory {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            # Validate that the provided path exists and is a directory
            if (-not(Test-Path -LiteralPath $_ -PathType Container)) {
                throw "Passed folder does not exist. ($_)"
            } else { return $true }
        })]
        [ValidateNotNullOrEmpty()]
        [Alias("PSPath","Directory","Folder")]
        [String[]] $LiteralPath,  # The root directory to start the recursive search for archives

        [ValidateSet('SameFolder','Subfolder', IgnoreCase = $true)]
        [String] $ExtractLocation = 'Subfolder', # Determines where extracted files will be placed

        [Switch] $DeleteArchives, # If set, deletes archives after extraction
        [Switch] $AutoRenameDuplicates, # If set, automatically renames duplicates during extraction
        [Int32] $MaxThreads = 16 # Maximum number of threads for parallel processing
    )

    begin {

        # Locate the 7-Zip command line tool
        $7zCMD = Get-Command 7z.exe -CommandType Application -ErrorAction SilentlyContinue
        if(-not($7zCMD)){
            $7zCMD = Get-Command 'C:\Program Files\7-Zip\7z.exe' -CommandType Application -ErrorAction SilentlyContinue
            if(-not($7zCMD)){
                throw "Can't locate 7z.exe (7-Zip Command Line) in PATH or Installation Directory."
            }
        }

        # Initialize a list to store directories
        $DirectoryList = [System.Collections.Generic.List[String]]@()
    }

    process {
        foreach ($Path in $LiteralPath) {
            # Add valid directories to the list
            if (Test-Path -Path $Path -PathType Container) {
                $DirectoryList.Add($Path)
            } else {
                Write-Error "Passed folder does not exist on disk: $Path" -ErrorAction Continue
            }
        }
    }

    end {

        # Define parameters for searching archive files once
        $getArchivesSplat = @{
            Recurse = $true
            Depth = 10
            File = $true
            Include = '*.zip', '*.7z', '*.rar', '*.cab',
                      '*.tar', '*.gz', '*.gzip', '*.tgz',
                      '*.lzh', '*.rpm', '*.deb', '*.dmg'
        }

        # Process each directory in parallel
        $DirectoryList | ForEach-Object -Parallel {

            # Use variables from the parent scope
            $7zCMD = $Using:7zCMD
            $DeleteArchives = $Using:DeleteArchives
            $ExtractLocation = $Using:ExtractLocation
            $getArchivesSplat = $Using:getArchivesSplat

            $Directory = $_
            $getArchivesSplat.Path = $Directory

            # Retrieve all archive files in the directory
            $Archives = Get-ChildItem @getArchivesSplat
            # If no archives are found, skip iteration
            if($Archives.Length -eq 0){ return }

            foreach ($Archive in $Archives) {

                # Extract file and directory information
                $ArchivePath = $Archive.FullName
                $ArchiveNoExtension = [System.IO.Path]::GetFileNameWithoutExtension($ArchivePath)
                $ArchiveFolder = [System.IO.Directory]::GetParent($ArchivePath).FullName

                # Determine extraction parameters based on user settings
                $OutputDir = if ($ExtractLocation -eq 'Subfolder') {
                    Join-Path -Path $ArchiveFolder -ChildPath $ArchiveNoExtension
                } else {
                    $ArchiveFolder
                }

                $7zParams = "x", $ArchivePath, "-o$OutputDir", "-y"
                if ($ExtractLocation -eq 'SameFolder' -and $AutoRenameDuplicates) {
                    $7zParams += "-aou"
                }

                # Execute the extraction command
                & $7zCMD $7zParams 2>&1 | Out-Null

                if($LASTEXITCODE -eq 0){
                    # Log successful extraction
                    Write-Host "Successfully extracted $ArchivePath" -f Blue
                    if($DeleteArchives){
                        try {
                            # Attempt to delete the archive after extraction
                            Remove-Item -LiteralPath $ArchivePath -Force | Out-Null
                            Write-Host "Successfully deleted $ArchivePath" -f Blue
                        }
                        catch {
                            Write-Error "Failed to delete archive after extraction ($ArchivePath)" -ErrorAction Continue
                        }
                    }
                }
                else {
                    # Log extraction failure
                    Write-Error "Failed to extract $ArchivePath" -ErrorAction Continue
                }
            }
        } -ThrottleLimit $MaxThreads
    }
}