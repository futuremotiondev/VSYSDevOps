<#
.SYNOPSIS
    Adds a string suffix to either a full path string or a filename string.

.DESCRIPTION
    This function takes a file path or filename string and adds a string suffix to it.
    It supports an option for specifying a separator between the base file name and the suffix.

.PARAMETER Path
    The file path or filename string to insert the suffix into. Supports pipeline input.

.PARAMETER Suffix
    The string suffix to add to the filename.

.PARAMETER Separator
    The separator to insert between the file base name and the suffix. Default is a space " ".

.EXAMPLE
    "C:\Users\Future\Desktop\document.txt" | Add-StringSuffixToFile -Suffix "v1"
    Output: "C:\Users\Future\Desktop\document v1.txt"

.EXAMPLE
    "project.ps1" | Add-StringSuffixToFile -Suffix "backup" -Separator "_"
    Output: "project_backup.ps1"

.EXAMPLE
    "C:\Files\image.jpg" | Add-StringSuffixToFile -Suffix "edited" -Separator "-"
    Output: "C:\Files\image-edited.jpg"

.NOTES
    Author: Futuremotion
    Date: July 16, 2024
    Website: https://github.com/futuremotiondev
#>
function Add-StringSuffixToFile {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]] $Path,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String] $Suffix,
        [String] $SuffixSeparator = " "
    )

    process {

        [Array] $Output = foreach ($String in $Path) {

            $Directory = [System.IO.Path]::GetDirectoryName($String)
            $FileName = [System.IO.Path]::GetFileNameWithoutExtension($String)
            $Extension = [System.IO.Path]::GetExtension($String)

            $NewFileName = "$FileName$SuffixSeparator$Suffix$Extension"

            if ($Directory) {
                $NewPath = Join-Path -Path $Directory -ChildPath $NewFileName
            } else {
                $NewPath = $NewFileName
            }

            $NewPath
        }

        $Output
    }
}