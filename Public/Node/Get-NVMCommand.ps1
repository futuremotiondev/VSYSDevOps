function Get-NVMCommand {
    [CmdletBinding()]

    $pathsToCheck = @(
        "nvm.exe",
        "nvm",
        "$env:NVM_HOME\nvm.exe",
        "C:\Users\$env:USERNAME\AppData\Roaming\nvm\nvm.exe"
    )
    foreach ($path in $pathsToCheck) {
        $NVMCmd = Get-Command $path -CommandType Application -ErrorAction SilentlyContinue
        if ($NVMCmd) { return $NVMCmd }
    }
    Write-Error "NVM (Node Version Manager) cannot be found. Make sure it's installed."
    return $null
}
