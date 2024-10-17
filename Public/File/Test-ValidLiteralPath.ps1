function Test-ValidLiteralPath {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]] $LiteralPath,
        [Switch] $OutputObject
    )

    begin {
        # Initialize constants once
        $InvalidChars = [System.IO.Path]::GetInvalidFileNameChars()
        $InvalidPathChars = [System.IO.Path]::GetInvalidPathChars()
        $DirectorySep = '\'

        if (!$IsWindows) {
            if ($VerboseOutput) { Write-Verbose "Detected environment is Linux/Unix" }
            $InvalidChars = $InvalidChars | Where-Object { $_ -ne '/' }
            $InvalidPathChars = $InvalidPathChars | Where-Object { $_ -ne '/' }
            $DirectorySep = '/'
        }
    }

    process {
        $Results = @()
        foreach ($path in $LiteralPath) {

            $isValid = $true
            $reason = "Valid LiteralPath"

            if ($OutputObject) {
                $Obj = [PSCustomObject]@{ Path = $path; Valid = $null; Reason = $null }
            }

            if ($path -match '[\?\*]') {
                Write-Verbose "Invalid: Passed path contains wildcards."
                $isValid = $false
                $reason = "Path contains wildcards"
            } elseif (($path -contains $InvalidChars) -or ($path -contains $InvalidPathChars)) {
                Write-Verbose "Invalid: Path contains invalid characters."
                $isValid = $false
                $reason = "Path contains invalid characters"
            } elseif (-not [System.IO.Path]::IsPathRooted($path)) {
                Write-Verbose "Invalid: Path is not rooted."
                $isValid = $false
                $reason = "Path is not rooted"
            } elseif (($path.Contains('/') -and $DirectorySep -eq '\') -or ($path.Contains('\') -and $DirectorySep -eq '/')) {
                Write-Verbose "Invalid: Directory Separators are invalid for this platform."
                $isValid = $false
                $reason = "Directory Separators are invalid"
            }

            if ($OutputObject) {
                $Obj.Valid = $isValid
                $Obj.Reason = $reason
                $Results += $Obj
            } else {
                $Results += $isValid
            }
        }

        $Results
    }
}