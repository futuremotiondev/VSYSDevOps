function Get-NVMNodeInstallationDirectory {
    if($env:NVM_SYMLINK){
        return $env:NVM_SYMLINK
    }
    else{
        return $null
    }
}