function Update-WindowsEnvironmentVariables {

    Write-Output "Refreshing environment variables..."

    $userName = $env:USERNAME
    $architecture = $env:PROCESSOR_ARCHITECTURE
    $psModulePath = $env:PSModulePath

    #ordering is important here, $user should override $machine...
    $ScopeList = 'Process', 'Machine'
    if ('SYSTEM', "${env:COMPUTERNAME}`$" -notcontains $userName) {
        # but only if not running as the SYSTEM/machine in which case user can be ignored.
        $ScopeList += 'User'
    }

    foreach ($Scope in $ScopeList) {
        Get-WindowsEnvironmentVariables -Scope $Scope |
        ForEach-Object {
            Set-Item "Env:$_" -Value (Get-WindowsEnvironmentVariable -Scope $Scope -Name $_)
        }
    }

    #Path gets special treatment b/c it munges the two together
    $paths = 'Machine', 'User' |
    ForEach-Object {
      (Get-WindowsEnvironmentVariable -Name 'PATH' -Scope $_) -split ';'
    } |
    Select-Object -Unique
    $Env:PATH = $paths -join ';'

    # PSModulePath is almost always updated by process, so we want to preserve it.
    $env:PSModulePath = $psModulePath

    # reset user and architecture
    if ($userName) {
        $env:USERNAME = $userName;
    }
    if ($architecture) {
        $env:PROCESSOR_ARCHITECTURE = $architecture;
    }

    Write-Output "Finished"
}