<#
.SYNOPSIS
    Flattens the directory structure by moving all files from subdirectories into a single directory.

.DESCRIPTION
    This function takes a list of directories, moves all files from their subdirectories into the root of each directory, and handles duplicate filenames by appending a specified padding.

.PARAMETER InputPath
    The list of directories to process. Only directories will be accepted.

.PARAMETER DuplicatePadding
    The number of padding characters to append to duplicate filenames. Default is 2.

.PARAMETER PaddingSeparator
    The separator to use between the original filename and the padding. Default is a space.

.PARAMETER MaxThreads
    The maximum number of threads to use for parallel processing. Default is 14.

.EXAMPLE
    ConvertTo-FlatDirectory -InputPath "C:\Folder1", "C:\Folder2"

    This example flattens the directory structure of "C:\Folder1" and "C:\Folder2".

.EXAMPLE
    ConvertTo-FlatDirectory -InputPath "C:\Folder1" -DuplicatePadding 3 -PaddingSeparator "_"

    This example flattens the directory structure of "C:\Folder1" and uses an underscore as the padding separator with 3 padding characters for duplicate filenames.

.EXAMPLE
    ConvertTo-FlatDirectory -InputPath "C:\Folder1" -MaxThreads 10

    This example flattens the directory structure of "C:\Folder1" using a maximum of 10 threads for parallel processing.

.NOTES
    Author: Futuremotion
    Date: 2023-10-10
    Website: https://github.com/futuremotiondev
#>
function ConvertTo-FlatDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [String[]] $InputPath,
        [int32] $DuplicatePadding = 2,
        [String] $PaddingSeparator = " ",
        [Int32] $MaxThreads = 14
    )

    begin {
        $PathList = [System.Collections.Generic.List[String]]@()
    }


    process {
        foreach ($Path in $InputPath) {
            if (Test-Path -Path $Path -PathType Container) {
                $PathList.Add($Path)
            } else {
                Write-Warning "Passed value is not a folder. ($Path)"
            }
        }
    }

    end {


        foreach ($Path in $PathList) {

            if (Test-DirectoryIsProtected -Path $Path) {
                throw "Passed path is a protected operating system directory or within one. ($Path)"
            }

            $TempPath = (New-TempDirectory).FullName
            Move-Item -Path $Path'\*' -Destination $TempPath -Force | Out-Null
            $AllFiles = [IO.DirectoryInfo]::new($TempPath).GetFiles('*', 'AllDirectories')

            $AllFiles | ForEach-Object -Parallel {

                $DuplicatePadding = $Using:DuplicatePadding
                $PaddingSeparator = $Using:PaddingSeparator

                $DestinationPath = $Using:Path
                $Filename = [System.IO.Path]::GetFileName($_)
                $FilepathInTemp = $_.FullName

                $DestFilepath = Join-Path $DestinationPath -ChildPath $Filename
                $DestFilepath = Get-UniqueFileOrFolderNameIfDuplicate -Path $DestFilepath

                Move-Item -LiteralPath $FilepathInTemp -Destination $DestFilepath -Force

            } -ThrottleLimit $MaxThreads
        }
    }
}
