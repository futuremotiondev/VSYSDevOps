function Get-NVMNodeInstallationDirectory {
    [CmdletBinding()]
    param()
    if($env:NVM_SYMLINK){
        return $env:NVM_SYMLINK
    }
    $NodePath = (Get-Command node.exe -CommandType Application).path
    $NodePath = [System.IO.Directory]::GetParent($NodePath).FullName
    if($NodePath){
        return $NodePath
    }
    Write-Error "Can't determine the Node.js Installation Directory."
    return $null

}