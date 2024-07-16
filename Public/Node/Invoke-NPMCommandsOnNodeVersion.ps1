function Invoke-NPMCommandsOnNodeVersion {
    param (
        [Parameter(Mandatory=$true)]
        [string] $NodeVersion,

        [Parameter(Mandatory=$true)]
        [string[]] $Commands
    )

    # Check if NVM is available
    try {
        $NVMCmd = Get-Command nvm.exe -CommandType Application
    } catch {
        Write-Error "Can't find nvm.exe (Node Version Manager)"
        throw $_
    }

    & $NVMCmd use $NodeVersion

    # Check if NPM is available
    try {
        $NPMCmd = Get-Command npm.cmd
    } catch {
        Write-Error "Can't find NPM (Is node installed correctly?)"
        throw $_
    }

    $modifiedCommands = $Commands | ForEach-Object {
        $_ -replace '^npm\s*', ''
    }

    foreach ($Cmd in $modifiedCommands) {
        Invoke-Expression "$NPMCmd $cmd"
    }
}
