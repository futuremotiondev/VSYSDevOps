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
        [String[]] $Path,
        [int32] $DuplicatePadding = 2,
        [String] $PaddingSeparator = " ",
        [Int32] $MaxThreads = 8
    )

    begin {
        $PathList = [System.Collections.Generic.List[String]]@()
    }


    process {
        foreach ($Folder in $Path) {
            $PathList.Add($Folder)
        }
    }

    end {

        if($PathList.Count -eq 1){
            $MaxThreads = 1
        }


        $PathList | ForEach-Object -Parallel {

            $Directory = $_
            $DuplicatePadding = $Using:DuplicatePadding
            $PaddingSeparator = $Using:PaddingSeparator

            if (Test-DirectoryIsProtected -Path $Directory) {
                throw "Passed path is a protected operating system directory or within one. ($Directory)"
            }

            $TempPath = (New-TempDirectory).FullName
            Move-Item -Path $Directory'\*' -Destination $TempPath -Force | Out-Null
            $AllFiles = [IO.DirectoryInfo]::new($TempPath).GetFiles('*', 'AllDirectories')

            $AllFiles | ForEach-Object -Parallel {

                $DuplicatePadding = $Using:DuplicatePadding
                $PaddingSeparator = $Using:PaddingSeparator

                $DestinationPath = $Using:Directory
                $Filename = [System.IO.Path]::GetFileName($_)
                $FilepathInTemp = $_.FullName

                $DestFilepath = Join-Path $DestinationPath -ChildPath $Filename
                $DestFilepath = Get-UniqueFileOrFolderNameIfDuplicate -Path $DestFilepath

                Move-Item -LiteralPath $FilepathInTemp -Destination $DestFilepath -Force | Out-Null

            } -ThrottleLimit 8

            $TempPath | Remove-Item -Recurse -Force

        } -ThrottleLimit $MaxThreads
    }
}
