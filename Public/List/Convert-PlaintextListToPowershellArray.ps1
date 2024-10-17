<#
.SYNOPSIS
Converts a list of plaintext strings into a PowerShell array declaration.

.DESCRIPTION
The `Convert-PlaintextListToPowershellArray` function takes a list of strings and converts it into a
PowerShell array declaration. It offers options to sort the items, strip quotes, copy the output to the
clipboard, and save the result to a file.

.PARAMETER ListItems
An array of strings representing the list items to be converted into a PowerShell array.

.PARAMETER CopyToClipboard
A switch parameter that, when specified, copies the resulting array declaration to the clipboard.

.PARAMETER StripQuotes
A switch parameter that, when specified, removes quotes from each item in the list before processing.

.PARAMETER Sort
Specifies the order in which to sort the list items. Acceptable values are 'Ascending' or 'Descending'.
The default is 'Ascending'.

.PARAMETER ArrayName
Specifies the name of the PowerShell array variable. Must match the pattern of word characters only.
Defaults to 'NewArray'.

.PARAMETER OutputFile
Specifies the path to a file where the resulting array declaration will be saved. If the file already
exists, a unique name will be generated.

.PARAMETER NoOutput
A switch parameter that, when specified, suppresses the output of the array declaration to the console.

.EXAMPLE
Convert-PlaintextListToPowershellArray -ListItems "apple", "banana", "cherry" -Sort Descending -ArrayName FruitArray

This example converts a list of fruits into a PowerShell array named `FruitArray`, sorted in descending order.

.EXAMPLE
Convert-PlaintextListToPowershellArray -ListItems "file1.txt", "file2.txt", "file3.txt" -CopyToClipboard -StripQuotes

This example converts a list of filenames into a PowerShell array, strips any quotes, and copies the result to the clipboard.

.EXAMPLE
Convert-PlaintextListToPowershellArray -ListItems "dog", "cat", "bird" -OutputFile "C:\temp\AnimalArray.ps1" -NoOutput

This example converts a list of animals into a PowerShell array and saves it to a file at `C:\temp\AnimalArray.ps1` without displaying the output in the console.

.NOTES
Author: Futuremotion
Date: 10-12-2024
URL: https://github.com/futuremotiondev
#>
function Convert-PlaintextListToPowershellArray {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]] $ListItems,
        [Switch] $CopyToClipboard,
        [Switch] $StripQuotes,
        [ValidateSet('Ascending','Descending')]
        [String] $Sort = 'Ascending',
        [ValidatePattern('^\w+$')]
        [String] $ArrayName = 'NewArray',

        [ValidateNotNullOrWhitespace()]
        [ValidateNotNullOrEmpty()]
        [String] $OutputFile,

        [Switch] $NoOutput,
        [Switch] $FilenamesOnly
    )

    if ($StripQuotes) { $ListItems = $ListItems.Trim('"') }
    if ($FilenamesOnly) {
        $ListItems = $ListItems | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }
    }
    $SortOutput = @{}
    if ($Sort -eq 'Descending') { $SortOutput['Descending'] = $true }
    $Output = @(
        '${0} = @(' -f $ArrayName
        $ListItems | Sort-Object @SortOutput | ForEach-Object { '    "{0}"' -f $_ }
        ')'
    )
    if($CopyToClipboard){ $Output | Set-Clipboard }
    if($OutputFile){
        $OutputFile = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputFile)
        $FinalFile = Get-UniqueNameIfDuplicate -LiteralPath $OutputFile
        [System.IO.File]::WriteAllLines($FinalFile, $Output)
    }
    if(!$NoOutput){ $Output }
}
