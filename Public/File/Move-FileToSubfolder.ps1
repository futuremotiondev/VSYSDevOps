function Move-FileToSubfolder {
    param(
        [string]$File,
        [string]$NewDirName
    )
    
    $BaseDir = [System.IO.Directory]::GetParent($File)
    $DestDir = Join-Path $BaseDir -ChildPath $NewDirName 
    if(-not($DestDir | Test-Path)){
        New-Item $DestDir -ItemType Directory | Out-Null
        Move-Item $File -Destination $DestDir
    } else {
        $FileBase = [System.IO.Path]::GetFileName($File)
        $DestPath = Join-Path $DestDir $FileBase
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