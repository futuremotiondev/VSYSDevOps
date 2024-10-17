function Get-NVMLatestNodeVersionInstalled {
    [CmdletBinding()]
    param ()

    $Latest = (Get-NVMInstalledNodeVersions)[0]
    if(!$Latest){
        Write-Error "Can't determine the latest node version installed with NVM."
        return $null
    }
    $Latest
}