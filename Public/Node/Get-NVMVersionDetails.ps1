function Get-NVMVersionDetails {

    $NVMCmd = Get-NVMCommand -ErrorAction Stop
    $NVMVersion = & $NVMCmd '--version'
    $ActiveVersion = Get-NVMActiveNodeVersion
    $Symlink = $env:NVM_SYMLINK

    $NodeExePath = [System.IO.Path]::Combine($Symlink, 'node.exe')
    if (-not (Test-Path -LiteralPath $NodeExePath -PathType Leaf)) {
        $NodeExePath = $null
    }

    return [PSCustomObject]@{
        Version = $NVMVersion
        NVM_HOME = $env:NVM_HOME
        NVM_SYMLINK = $env:NVM_SYMLINK
        NodeExe = $NodeExePath
        ActiveNode = $ActiveVersion
        ActiveNodeHome = [System.IO.Path]::Combine($env:NVM_HOME, "v$ActiveVersion")
    }
}
