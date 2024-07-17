<#
.SYNOPSIS
    Generates a unique file or folder name if a duplicate exists at the specified path.

.DESCRIPTION
    The Get-UniqueFileOrFolderNameIfDuplicate function checks if a file or folder with the given path already exists.
    If it does, the function generates a new unique name by appending an incrementing index to the original name.
    This is useful for avoiding name conflicts when creating new files or folders.

.PARAMETER Path
    The path of the file or folder to check for duplicates. This parameter is mandatory.

.PARAMETER PadIndexTo
    The number of digits to pad the index to. Default is 2.

.PARAMETER IndexStart
    The starting value for the index. Default is 2.

.PARAMETER IndexSeparator
    The separator to use between the original name and the index. Default is a space.

.EXAMPLE
    PS C:\> Get-UniqueFileOrFolderNameIfDuplicate -Path "C:\MyFolder\example.txt"

    If "example.txt" already exists in "C:\MyFolder", this command will return a new unique name like "example 02.txt".

.EXAMPLE
    PS C:\> Get-UniqueFileOrFolderNameIfDuplicate -Path "C:\MyFolder\example.txt" -PadIndexTo 3 -IndexStart 1 -IndexSeparator "_"

    If "example.txt" already exists in "C:\MyFolder", this command will return a new unique name like "example_001.txt".

.EXAMPLE
    PS C:\> Get-UniqueFileOrFolderNameIfDuplicate -Path "C:\MyFolder\.example"

    If ".example" already exists in "C:\MyFolder", this command will return a new unique name like ".example 02".

.NOTES
    Author: Futuremotion
    Date: 2023-10-05
    Website: https://github.com/futuremotiondev
#>
function Get-UniqueFileOrFolderNameIfDuplicate {

    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string[]] $Path,
        [Int32]$PadIndexTo = 2,
        [Int32]$IndexStart = 2,
        [String]$IndexSeparator = " "
    )

    process {

        [Array] $Output = foreach ($FilePath in $Path) {

            $fileOrFolderName = Split-Path -Path $FilePath -Leaf
            $parentDirectory = Split-Path -Path $FilePath -Parent

            if (Test-Path -Path $FilePath) {

                $counter = $IndexStart
                $newName = $fileOrFolderName

                if (Test-Path -Path $FilePath -PathType Leaf) {
                    # If the path is a file
                    if ($fileOrFolderName.StartsWith(".")) {
                        # If the file is a dotfile
                        while (Test-Path -Path (Join-Path -Path $parentDirectory -ChildPath $newName)) {
                            $paddedCounter = $counter.ToString().PadLeft($PadIndexTo, '0')
                            $newName = "{0}{1}{2}" -f $fileOrFolderName, $IndexSeparator, $paddedCounter
                            $counter++
                        }
                    }
                    else {
                        # If the file has an extension
                        $lastDotIndex = $fileOrFolderName.LastIndexOf(".")
                        if ($lastDotIndex -ne -1) {
                            $fileNameWithoutExtension = $fileOrFolderName.Substring(0, $lastDotIndex)
                            $extension = $fileOrFolderName.Substring($lastDotIndex)
                            while (Test-Path -Path (Join-Path -Path $parentDirectory -ChildPath $newName)) {
                                $paddedCounter = $counter.ToString().PadLeft($PadIndexTo, '0')
                                $newName = "{0}{1}{2}{3}" -f $fileNameWithoutExtension, $IndexSeparator, $paddedCounter, $extension
                                $counter++
                            }
                        }
                        else {
                            # If the file has no extension
                            while (Test-Path -Path (Join-Path -Path $parentDirectory -ChildPath $newName)) {
                                $paddedCounter = $counter.ToString().PadLeft($PadIndexTo, '0')
                                $newName = "{0}{1}{2}" -f $fileOrFolderName, $IndexSeparator, $paddedCounter
                                $counter++
                            }
                        }
                    }
                }
                else {
                    # If the path is a folder
                    while (Test-Path -Path (Join-Path -Path $parentDirectory -ChildPath $newName)) {
                        $paddedCounter = $counter.ToString().PadLeft($PadIndexTo, '0')
                        $newName = "{0}{1}{2}" -f $fileOrFolderName, $IndexSeparator, $paddedCounter
                        $counter++
                    }
                }
                Join-Path $parentDirectory -ChildPath $newName
            }
            else {
                $FilePath
            }
        }

        $Output
    }
}