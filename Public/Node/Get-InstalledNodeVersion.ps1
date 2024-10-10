function Get-InstalledNodeVersion {
    $nodePath = (Get-Command node.exe -ErrorAction SilentlyContinue).Path
    if ($nodePath) {
        $version = node --version
        [PSCustomObject]@{
            Path    = $nodePath
            Version = $version
        }
    } else {
        return $null
    }
}