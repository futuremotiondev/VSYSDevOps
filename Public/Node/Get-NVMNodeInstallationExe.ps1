function Get-NVMNodeInstallationExe {
    if($env:NVM_SYMLINK){
        $NodePath = Join-Path -LiteralPath $env:NVM_SYMLINK -ChildPath 'node.exe'
        return $NodePath
    }
    else{
        return $null
    }
}