# REFACTOR: Combine with Test-PathIsLikelyFile
function Test-PathIsLikelyDirectory {
    [CmdletBinding()]
    param(
        [parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path
    )

    begin {}

    process {
        $Path | ForEach-Object {
            $File = $_
            $NormalizedPath = $File -replace '/', '\'
            $EndsWithSeparator = $NormalizedPath -match '\\$'
            $LastPart = $NormalizedPath -split '\\' | Select-Object -Last 1
            $LikelyFile = $LastPart -match '\.[^\.]+$'
            if ($LikelyFile) {
                return $false
            }
            elseif ($EndsWithSeparator -or -not $LastPart.Contains('.')) {
                return $true
            }
            else {
                return $false
            }
        }
    }
}