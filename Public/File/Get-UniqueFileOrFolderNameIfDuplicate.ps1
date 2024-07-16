function Get-UniqueFileOrFolderNameIfDuplicate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Int32]$PadIndexTo = 2,
        [Int32]$IndexStart = 2,
        [String]$IndexSeparator = " "
    )
    $fileOrFolderName = Split-Path -Path $Path -Leaf
    $parentDirectory = Split-Path -Path $Path -Parent
    if (Test-Path -Path $Path) {
        $counter = $IndexStart
        $newName = $fileOrFolderName
        if (Test-Path -Path $Path -PathType Leaf) {
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
        return (Join-Path $parentDirectory -ChildPath $newName)
    }
    else {
        return $Path
    }
}