<#
.SYNOPSIS
Converts a plaintext list to a PowerShell array.

.DESCRIPTION
The Convert-PlaintextListToArray function takes a list of strings and converts it into a formatted PowerShell array.
The function also provides options to sort the list, strip quotes from input, and either save the output to a file or copy it to the clipboard.

.PARAMETER ListItems
An array of strings that will be converted into a PowerShell array.

.PARAMETER SaveAsFile
A switch parameter that, when used, saves the output to a file.

.PARAMETER DestFile
The destination file where the output will be saved when the SaveAsFile switch is used.

.PARAMETER CopyToClipboard
A switch parameter that, when used, copies the output to the clipboard.

.PARAMETER SortList
A switch parameter that, when used, sorts the list items.

.PARAMETER StripQuotesFromInput
A switch parameter that, when used, removes quotes from the input list items.

.PARAMETER ArrayName
The name of the array in the output. Defaults to 'CustomArray'.

.EXAMPLE
Convert-PlaintextListToArray -ListItems 'Apple', 'Banana', 'Cherry' -CopyToClipboard

This example converts the list 'Apple', 'Banana', 'Cherry' into a PowerShell array and copies it to the clipboard.

.EXAMPLE
Convert-PlaintextListToArray -ListItems 'Zebra', 'Antelope', 'Elephant' -SortList -StripQuotesFromInput -SaveAsFile -DestFile 'C:\temp\animals.txt'

This example converts the list 'Zebra', 'Antelope', 'Elephant' into a sorted PowerShell array, removes quotes from the input, and saves it to the file 'C:\temp\animals.txt'.

.EXAMPLE
Convert-PlaintextListToArray -ListItems 'Red', 'Green', 'Blue' -ArrayName 'Colors' -SaveAsFile -DestFile 'C:\temp\colors.txt'

This example converts the list 'Red', 'Green', 'Blue' into a PowerShell array with the name 'Colors' and saves it to the file 'C:\temp\colors.txt'.

.NOTES
Author: Futuremotion
Website: https://www.github.com/fmotion1
#>
function Convert-PlaintextListToArray {
    param(

        [Parameter(Mandatory)]
        [string[]] $ListItems,

        [Parameter(Mandatory,ParameterSetName='SaveFile')]
        [Switch] $SaveAsFile,

        [Parameter(Mandatory,ParameterSetName='SaveFile')]
        [String] $DestFile,

        [Parameter(Mandatory,ParameterSetName='Clipboard')]
        [Switch] $CopyToClipboard,

        [Parameter(Mandatory=$false,ParameterSetName='SaveFile')]
        [Parameter(Mandatory=$false,ParameterSetName='Clipboard')]
        [Switch] $SortList,

        [Parameter(Mandatory=$false,ParameterSetName='SaveFile')]
        [Parameter(Mandatory=$false,ParameterSetName='Clipboard')]
        [Switch] $StripQuotesFromInput,

        [Parameter(Mandatory=$false,ParameterSetName='SaveFile')]
        [Parameter(Mandatory=$false,ParameterSetName='Clipboard')]
        [String] $ArrayName = 'CustomArray'

    )

    if($SortList){
        $ListItems = $ListItems | Format-ObjectSortNumerical
    }

    if($StripQuotesFromInput){
        $reStripQuotesPattern = '".*?"'
        $ListItems = $ListItems | ForEach-Object {
            if ($_ -match $reStripQuotesPattern) {
                $_ -replace '"', ''
            } else {
                $_
            }
        }
    }

    $FormattedArray = "`$$ArrayName = @(`n"
    foreach ($Path in $ListItems) {

        $FormattedArray += "    `"$Path`",`n"
    }
    $FormattedArray = $FormattedArray.TrimEnd(",`n")
    $FormattedArray += "`n)"

    if($PSCmdlet.ParameterSetName -eq 'Clipboard'){
        $FormattedArray | Set-Clipboard
    }
    elseif($PSCmdlet.ParameterSetName -eq 'SaveFile') {

        $IDX = 2
        $PadIndexTo = '1'
        $StaticFilename = $DestFile.Substring(0, $DestFile.LastIndexOf('.'))
        $FileExtension  = [System.IO.Path]::GetExtension($DestFile)
        while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
            $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
            $IDX++
        }

        [System.IO.File]::WriteAllLines($DestFile, $FormattedArray)
    }
}