# REFACTOR: Add support for Linux, forward-slashes, Double back-slashes and clean up
# current code.
function Copy-WindowsPathToClipboard {
    param(
        [string[]]$Path,
        [switch]$FilenamesOnly,
        [switch]$NoQuotes,
        [switch]$ForwardSlashes,
        [switch]$DoubleBackslashes,
        [switch]$NoExtension,
        [switch]$AsArray
    )

    # Check for incompatible switch combination
    if ($AsArray -and $NoQuotes) {
        throw "AsArray and NoQuotes switches cannot be used together."
    }

    if($ForwardSlashes -and $DoubleBackslashes){
        throw "ForwardSlashes and DoubleBackslashes switches cannot be used together."
    }

    # Separate files and folders for individual processing
    $files = @()
    $folders = @()

    foreach ($item in $Path) {

        Write-Host "`$Path:" $Path -ForegroundColor Green

        if (Test-Path -LiteralPath $item -PathType Leaf) {
            $files += $item
        } elseif (Test-Path -LiteralPath $item -PathType Container) {
            $folders += $item
        }
    }

    # Define a helper function to process paths
    function Process-Path {
        param(
            [string]$Path,
            [bool]$IsFile
        )

        $fileName = [System.IO.Path]::GetFileName($Path)
        $extension = [System.IO.Path]::GetExtension($Path)
        $directory = [System.IO.Path]::GetDirectoryName($Path)

        # Extract filename or folder name if required
        if ($FilenamesOnly) {
            if ($IsFile -and -not $NoExtension) {
                # Keep the extension for files when $NoExtension is not set
                $Path = $fileName
            } else {
                # Remove extension if $NoExtension is set or item is a folder
                $Path = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
            }
        } elseif ($NoExtension -and $IsFile) {
            # Remove extension from files if required
            $Path = [System.IO.Path]::Combine($directory, [System.IO.Path]::GetFileNameWithoutExtension($fileName))
        }

        # Add quotes if required and not outputting as an array
        if (-not $NoQuotes -and -not $AsArray) {
            $Path = "`"$Path`""
        }

        return $Path
    }

    # Process files and folders
    $processedFiles = $files | ForEach-Object { Process-Path -Path $_ -IsFile $true }
    $processedFolders = $folders | ForEach-Object { Process-Path -Path $_ -IsFile $false }

    # Sort files and folders numerically
    $sortedFiles = $processedFiles | Format-ObjectSortNumerical
    $sortedFolders = $processedFolders | Format-ObjectSortNumerical

    # Combine sorted folders and files
    $combinedPaths = $sortedFolders + $sortedFiles

    if($ForwardSlashes){
        [Array] $NewCombinedPaths = @()
        foreach ($Path in $combinedPaths) {
            $Path = $Path -replace "\\", '/'
            $NewCombinedPaths += $Path
        }
        $combinedPaths = $NewCombinedPaths
    }

    if($DoubleBackslashes){
        [Array] $NewCombinedPaths = @()
        foreach ($Path in $combinedPaths) {
            $Path = $Path -replace '\\', '\\'
            $NewCombinedPaths += $Path
        }
        $combinedPaths = $NewCombinedPaths
    }

    # Format as a PowerShell array if required
    if ($AsArray) {
        $formattedArray = "`$OutputArray = @(`n"
        foreach ($path in $combinedPaths) {
            $formattedArray += "    `"$path`",`n"
        }
        $formattedArray = $formattedArray.TrimEnd(",`n")  # Remove the last comma
        $formattedArray += "`n)"

        # Set the formatted array to the clipboard
        $formattedArray | Set-Clipboard
    } else {
        # Clear the clipboard before setting the new content
        [System.Windows.Forms.Clipboard]::Clear()

        # Copy the combined, processed paths to the clipboard
        $combinedPaths | Set-Clipboard
    }
}
