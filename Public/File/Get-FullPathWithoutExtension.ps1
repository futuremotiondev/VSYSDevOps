function Get-FullPathWithoutExtension {
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]] $LiteralPath,
        [Int32] $MaxThreads = 16
    )

    process {
        $LiteralPath | ForEach-Object -Parallel {
            if(Test-Path -LiteralPath $_ -PathType Container){
                [System.IO.Path]::TrimEndingDirectorySeparator($_)
            }
            else {
                $_.Substring(0, $_.LastIndexOf('.'))
            }
        } -ThrottleLimit $MaxThreads
    }
}