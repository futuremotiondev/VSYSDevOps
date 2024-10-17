function Get-NPMCommand {
    [CmdletBinding()]

    $pathsToCheck = @(
        "npm.cmd",
        "$env:NVM_HOME\npm.cmd",
        "$env:NVM_SYMLINK\npm.cmd"
    )
    foreach ($path in $pathsToCheck) {
        $NPMCmd = Get-Command $path -CommandType Application -ErrorAction SilentlyContinue
        if ($NPMCmd) { return $NPMCmd }
    }

    Write-Error "NPM (Node Package Manager) cannot be found. Make sure your node installation is configured properly."
    return $null
}
