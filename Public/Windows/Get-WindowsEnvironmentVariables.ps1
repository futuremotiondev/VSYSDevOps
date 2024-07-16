<#
    .SYNOPSIS
    Gets all environment variable names.

    .DESCRIPTION
    Provides a list of environment variable names based on the scope. This
    can be used to loop through the list and generate names.

    .NOTES
    Process dumps the current environment variable names in memory /
    session. The other scopes refer to the registry values.

    .INPUTS
    None

    .OUTPUTS
    A list of environment variables names.

    .EXAMPLE
    Get-WindowsEnvironmentVariables -Machine
#>

# TODO: Get-WindowsEnvironmentVariable and Set-WindowsEnvironmentVariable
# TODO: Cross Platform support
function Get-WindowsEnvironmentVariables {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.EnvironmentVariableTarget] $Scope
    )

    # HKCU:\Environment may not exist in all Windows OSes (such as Server Core).
    $USER_ENV_REGKEY = 'HKCU:\Environment'
    $MACHINE_ENV_REGKEY = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'

    switch ($Scope) {
        'Machine' {
            Get-Item $MACHINE_ENV_REGKEY | Select-Object -ExpandProperty Property
        }
        'User' {
            Get-Item $USER_ENV_REGKEY -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
        }
        'Process' {
            Get-ChildItem Env:\ | Select-Object -ExpandProperty Key
        }
        default {
            throw "Unsupported environment scope: $Scope"
        }
    }
}