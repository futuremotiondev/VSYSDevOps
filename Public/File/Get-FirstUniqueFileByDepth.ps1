<#
.SYNOPSIS
    Searches for the first unique file by name within a specified directory and depth.

.DESCRIPTION
    The Get-FirstUniqueFileByDepth function searches for a file with a specified name within a given directory.
    The search can be limited by a specified depth, which determines how many levels of subdirectories will be checked.

.PARAMETER Directory
    The directory in which to start the search. This parameter is mandatory and accepts input from the pipeline.

.PARAMETER FileName
    The name of the file to search for. This parameter is mandatory and accepts input from the pipeline by property name.

.PARAMETER Depth
    The depth to which the search should be performed. This parameter is optional and defaults to 2 if not specified.
    The depth determines how many levels of subdirectories will be checked.

.EXAMPLE
    PS C:\> Get-FirstUniqueFileByDepth -Directory "C:\MyFolder" -FileName "example.txt" -Depth 3

    This command searches for the file "example.txt" within "C:\MyFolder" and its subdirectories up to a depth of 3 levels.

.EXAMPLE
    PS C:\> "C:\MyFolder" | Get-FirstUniqueFileByDepth -FileName "example.txt"

    This command searches for the file "example.txt" within "C:\MyFolder" and its subdirectories up to the default depth of 2 levels.

.NOTES
    Author: Futuremotion
    Date: 07-16-2024
#>

function Get-FirstUniqueFileByDepth {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String] $Directory,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String] $FileName,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int] $Depth = 2
    )

    process {

        $SearchFile = {
            param (
                [String] $CurrentDirectory,
                [Int] $CurrentDepth
            )

            if ($CurrentDepth -le 0) {
                return $null
            }

            # Check for the file directly in the current directory
            $DirectFile = Get-ChildItem -Path $CurrentDirectory -Filter $FileName -File
            if ($DirectFile) {
                return $DirectFile.FullName
            }
            else {
                # If not found directly, check the next level deeper based on remaining depth
                $subDirectories = Get-ChildItem -Path $CurrentDirectory -Directory
                foreach ($subDir in $subDirectories) {
                    $foundFile = & $SearchFile -CurrentDirectory $subDir.FullName -CurrentDepth ($CurrentDepth - 1)
                    if ($foundFile) {
                        return $foundFile
                    }
                }
            }

            # Return $null if no file is found within the specified depth
            return $null
        }

        # Start searching from the specified directory with the initial depth
        return & $SearchFile -CurrentDirectory $Directory -CurrentDepth $Depth
    }
}