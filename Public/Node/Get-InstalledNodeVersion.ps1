function Get-InstalledNodeVersion {
    [CmdletBinding()]
    $nodePath = (Get-Command node.exe -ErrorAction SilentlyContinue).Path
    if ($nodePath) {
        $version = node --version
        [PSCustomObject]@{
            Path    = $nodePath
            Version = $version
        }
    } else {
        Write-Error "Could not determine installed Node.js version and path."
        return $null
    }
}