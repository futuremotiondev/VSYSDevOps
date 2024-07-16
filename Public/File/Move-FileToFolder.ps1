function Move-FileToFolder {
    param(
        [string]$File,
        [string]$DestFolder
    )

    $FileBase = [System.IO.Path]::GetFileName($File)
    if(-not($DestFolder | Test-Path)){
        New-Item $DestFolder -ItemType Directory | Out-Null
        Move-Item $File -Destination $DestFolder
    } else {
        $DestPath = Join-Path $DestFolder $FileBase
        $IDX = 2
        $PadIndexTo = '1'
        $StaticFilename = $DestPath.Substring(0, $DestPath.LastIndexOf('.'))
        $FileExtension  = [System.IO.Path]::GetExtension($FileBase)
        while (Test-Path -LiteralPath $DestPath -PathType Leaf) {
            $DestPath = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
            $IDX++
        }
        Move-Item $File -Destination $DestPath
    }
}


