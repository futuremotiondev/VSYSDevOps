<#
.SYNOPSIS
    Generates a unique file or folder name if a duplicate exists in the specified path.

.DESCRIPTION
    The `Get-UniqueNameIfDuplicate` function takes an array of file or folder paths and checks for duplicates.
    If a duplicate is found, it generates a new unique name by appending a counter to the base name.
    This function can handle files with or without extensions as well as dotfiles.

.PARAMETER LiteralPath
    An array of file or folder paths to check for duplicates.

.PARAMETER IndexStart
    The starting value for the counter appended to the base name. Default is 1.

.PARAMETER PadIndexTo
    The number of digits to pad the counter to. Default is 3.

.PARAMETER IndexSeparator
    The separator string between the base name and the counter. Default is a space (" ").

.EXAMPLE
    PS> Get-UniqueNameIfDuplicate -LiteralPath "C:\data\report.docx"
    C:\data\report 001.docx

.EXAMPLE
    PS> Get-UniqueNameIfDuplicate -LiteralPath "C:\projects\code.py", "C:\projects\code.py"
    C:\projects\code 001.py
    C:\projects\code 002.py

.EXAMPLE
    PS> Get-UniqueNameIfDuplicate -LiteralPath "C:\images\photo.jpg" -IndexStart 10 -PadIndexTo 4 -IndexSeparator "-"
    C:\images\photo-0010.jpg

.NOTES
    Author: Futuremotion
    Date: 2023-10-09
    Website: https://github.com/futuremotiondev
#>
function Get-UniqueNameIfDuplicate {
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [Alias("Path")]
        [ValidateNotNullOrEmpty()]
        [string[]] $LiteralPath,
        [Int] $IndexStart = 2,
        [Int] $PadIndexTo = 2,
        [String] $IndexSeparator = " "
    )

    process {
        [Array] $Output = foreach ($File in $LiteralPath) {

            $FileName = Split-Path -Path $File -Leaf
            $ParentDir = Split-Path -Path $File -Parent
            $counter = $IndexStart

            if (Test-Path -Path $File -PathType Leaf) {
                if ($FileName.StartsWith(".")) {
                    # Dotfile
                    $BaseName = $FileName
                    $Extension = ""
                } else {
                    $lastDotIndex = $FileName.LastIndexOf(".")
                    if ($lastDotIndex -ne -1) {
                        # File with extension
                        $BaseName = $FileName.Substring(0, $lastDotIndex)
                        $Extension = $FileName.Substring($lastDotIndex)
                    } else {
                        # File without extension
                        $BaseName = $FileName
                        $Extension = ""
                    }
                }
            } else {
                # Folder
                $BaseName = $FileName
                $Extension = ""
            }

            $NewName = $FileName

            while (Test-Path -Path (Join-Path -Path $ParentDir -ChildPath $NewName)) {

                $paddedCounter = $counter.ToString().PadLeft($PadIndexTo, '0')
                if ($Extension) {
                    $NewName = "{0}{1}{2}{3}" -f $BaseName, $IndexSeparator, $paddedCounter, $Extension
                } else {
                    $NewName = "{0}{1}{2}" -f $BaseName, $IndexSeparator, $paddedCounter
                }
                $counter++
            }

            Join-Path $ParentDir -ChildPath $NewName
        }
        $Output
    }
}