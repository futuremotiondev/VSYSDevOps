function Get-NVMVersion {
    $NVMCmd = Get-NVMCommand -ErrorAction Stop
    if (!$NVMCmd) { return $null }
    $NVMVersion = & $NVMCmd '--version'
    return $NVMVersion
}