function Get-NVMInstallationDirectory {
    $NVMCmd = Get-Command nvm.exe -CommandType Application -ErrorAction SilentlyContinue
    if(!$NVMCmd){
        throw "nvm.exe (Node Version Manager) can't be found. Make sure it's installed."
    }
    $NVMRootDir = (((& $NVMCmd "root") -split "`n")[1]) -replace 'Current Root: ', '' -replace '^[\s]+(.*)$', '$1'
    if([String]::IsNullOrEmpty($NVMRootDir)){
        return $null
    }
    else{
        return $NVMRootDir
    }
}
