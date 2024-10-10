function Remove-EmptyDirectories {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo[]] $Directories,
        [Int32] $Depth = 10
    )

    process {
        foreach ($Dir in $Directories) {
            if (-not (Test-Path -Path $Dir -PathType Container)) {
                Write-Warning "The path '$Dir' does not exist or is not a directory."
                continue
            }
            try {
                # Recursively remove empty directories
                Get-ChildItem -Directory -Recurse -Depth $Depth -Path $Dir | ForEach-Object {
                    if (-not (Get-ChildItem -Path $_.FullName -Recurse -Depth $Depth)) {
                        if ($PSCmdlet.ShouldProcess($_.FullName, "Remove empty directory")) {
                            Remove-Item -Force -Recurse -Path $_.FullName
                            Write-Verbose "Removed empty directory: $($_.FullName)"
                        }
                    }
                }
                # Check the root directory itself
                if (-not (Get-ChildItem -Path $Dir -Recurse -Depth $Depth)) {
                    if ($PSCmdlet.ShouldProcess($Dir.FullName, "Remove empty directory")) {
                        Remove-Item -Force -Recurse -Path $Dir
                        Write-Verbose "Removed empty directory: $($Dir.FullName)"
                    }
                }
            } catch {
                Write-Error "Failed to remove directory '$Dir': $_"
            }
        }
    }
}