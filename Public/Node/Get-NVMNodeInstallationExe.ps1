function Get-NVMNodeInstallationExe {
    [CmdletBinding()]
    param()
    if($env:NVM_SYMLINK){
        $NodePath = Join-Path -LiteralPath $env:NVM_SYMLINK -ChildPath 'node.exe'
        return $NodePath
    }
    $NodePath = (Get-Command node.exe -CommandType Application).path
    if($NodePath){ return $NodePath }
    Write-Error "Couldn't determine the path to node.exe"
    return $null
}