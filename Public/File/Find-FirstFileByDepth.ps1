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