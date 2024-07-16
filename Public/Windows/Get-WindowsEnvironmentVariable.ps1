 using namespace Microsoft.Win32
 <#
    .SYNOPSIS
    Gets an Environment Variable.

    .DESCRIPTION
    This will will get an environment variable based on the variable name
    and scope while accounting whether to expand the variable or not
    (e.g.: `%TEMP%`-> `C:\User\Username\AppData\Local\Temp`).

    .NOTES
    This helper reduces the number of lines one would have to write to get
    environment variables, mainly when not expanding the variables is a
    must.

    .PARAMETER Name
    The environment variable you want to get the value from.

    .PARAMETER Scope
    The environment variable target scope. This is `Process`, `User`, or
    `Machine`.

    .PARAMETER PreserveVariables
    A switch parameter stating whether you want to expand the variables or
    not. Defaults to false.

    .PARAMETER IgnoredArguments
    Allows splatting with arguments that do not apply. Do not use directly.

    .EXAMPLE
    Get-WindowsEnvironmentVariable -Name 'TEMP' -Scope User -PreserveVariables

    .EXAMPLE
    Get-WindowsEnvironmentVariable -Name 'PATH' -Scope Machine

#>
function Get-WindowsEnvironmentVariable {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [System.EnvironmentVariableTarget] $Scope
    )

    [string] $MACHINE_REG = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment\";
    [string] $USER_REG = "Environment";

    switch ($Scope) {
        'Machine'  {
            [RegistryKey] $RegKey = [Registry]::LocalMachine.OpenSubKey($MACHINE_REG)
        }
        'User' {
            [RegistryKey] $RegKey = [Registry]::CurrentUser.OpenSubKey($USER_REG)
        }
        'Process' {
            return [Environment]::GetEnvironmentVariable($Name, $Scope)
        }
        default {
            throw "Unknown environment variable scope: $Scope"
        }
    }

    [string] $envValue = ''
    if ($RegKey -ne $null) {
        try {
            # Some versions of Windows do not have HKCU:\Environment
            $envValue = $RegKey.GetValue($Name, [string]::Empty)
        }
        catch {
            Write-Error "Unable to retrieve the $Name environment variable."
        }
        finally {
            $RegKey.Close()
        }
    }

    if ([String]::IsNullOrEmpty($envValue)) {
        $envValue = [Environment]::GetEnvironmentVariable($Name, $Scope)
    }

    return $envValue
}