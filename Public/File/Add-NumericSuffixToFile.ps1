<#
.SYNOPSIS
    Adds a numeric suffix to either a full path string or a filename string.

.DESCRIPTION
    This function takes a file path or filename string and adds a numeric suffix to it.
    It supports options for specifying a separator, a prefix before the suffix, and zero-padding for the suffix number.

.PARAMETER Path
    The file path or filename string to insert the suffix into. Supports pipeline input.

.PARAMETER Number
    The numeric suffix to add to the filename.

.PARAMETER PreSuffix
    An optional string to insert before the numeric suffix.

.PARAMETER Separator
    The separator to insert between the file base name and the suffix. Default is a space " ".

.PARAMETER ZeroPadding
    The amount of zero-padding to add to the suffix. Default is 1.

.EXAMPLE
    "C:\PC\Benchmarks\cachemem.png" | Add-NumericSuffixToFile -Number 2 -ZeroPadding 2
    Output: "C:\PC\Benchmarks\cachemem 02.png"

.EXAMPLE
    "Save-FileHash.ps1" | Add-NumericSuffixToFile -Number 1 -Separator "_" -ZeroPadding 1
    Output: "Save-FileHash_1.ps1"

.EXAMPLE
    "C:\Test Images\Float 32 Bit\RAW Signature Edits 22 32Bit Float.tif" | Add-NumericSuffixToFile -Number 5 -ZeroPadding 3
    Output: "C:\Test Images\Float 32 Bit\RAW Signature Edits 22 32Bit Float 005.tif"

.EXAMPLE
    "C:\Users\Username\Documents\report.docx" | Add-NumericSuffixToFile -Number 3 -PreSuffix "v" -ZeroPadding 2
    Output: "C:\Users\Username\Documents\report v03.docx"

.NOTES
    Author: Futuremotion
    Date: July 16, 2024
    Website: https://github.com/futuremotiondev
#>
function Add-NumericSuffixToFile {
    [OutputType([string])]
    [CmdletBinding()]

    param (

        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]] $Path,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Int32] $Number,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String] $PreSuffix,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String] $Separator = " ",

        [Parameter(ValueFromPipelineByPropertyName)]
        [Int32] $ZeroPadding = 1
    )

    process {

        [Array] $Output = foreach ($String in $Path) {

            $Directory = [System.IO.Path]::GetDirectoryName($String)
            $FileName = [System.IO.Path]::GetFileNameWithoutExtension($String)
            $Extension = [System.IO.Path]::GetExtension($String)

            $FormattedNumber = $Number.ToString("D$ZeroPadding")
            $NewFileName = "$FileName$Separator$PreSuffix$FormattedNumber$Extension"

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