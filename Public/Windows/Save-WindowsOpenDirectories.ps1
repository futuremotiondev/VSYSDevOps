function Save-WindowsOpenDirectories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [String] $DestinationFolder,

        [Parameter(Mandatory=$false)]
        [String] $DestinationFilename
    )

    if([String]::IsNullOrEmpty($DestinationFolder)){
        $DestinationFolder = $PWD
    }
    if([String]::IsNullOrEmpty($DestinationFilename)){
        $Date = Get-Date -Format "MM-dd-yyyy HH-mm-ss"
        $DestinationFilename = "${Date}.txt"
    }

    $DestinationFile = Join-Path $DestinationFolder -ChildPath $DestinationFilename
    $DPath = Get-UniqueNameIfDuplicate -LiteralPath $DestinationFile
    New-Item -Path $DPath -ItemType File -Force | Out-Null

    [Array] $oWindows = Get-WindowsOpenDirectories
    $oWindows | ForEach-Object {
        if(-not([String]::IsNullOrEmpty($_))){
            $_ | Add-Content -Path $DPath
        }
    }
}