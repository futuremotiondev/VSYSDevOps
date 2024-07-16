# REFACTOR: Combine with Test-PathIsLikelyDirectory
function Test-PathIsLikelyFile {
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
            $LastPart = $NormalizedPath -split '\\' | Select-Object -Last 1
            $LikelyFile = $LastPart -match '\.[^\.]+$'
            if ($LikelyFile) {
                return $true
            } else {
                return $false
            }
        }
    }
}