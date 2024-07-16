<#
    .SYNOPSIS
    Get the operating system architecture address width.

    .DESCRIPTION
    This will return the system architecture address width (probably 32 or
    64 bit). If you pass a comparison, it will return true or false instead
    of {`32`|`64`}.

    .NOTES
    When your installation script has to know what architecture it is run
    on, this simple function comes in handy.

    ARM64 architecture will automatically select 32bit width as
    there is an emulator for 32 bit and there are no current plans by Microsoft to
    ship 64 bit x86 emulation for ARM64. For more details, see
    https://github.com/chocolatey/choco/issues/1800#issuecomment-484293844.

#>
# REFACTOR: Code quality. Linux support.
function Get-WindowsOSArchitecture {

    $bits = 64
    if (([System.IntPtr]::Size -eq 4) -and (Test-Path env:\PROCESSOR_ARCHITEW6432)) {
        $bits = 64
    }
    elseif ([System.IntPtr]::Size -eq 4) {
        $bits = 32
    }

    $processorArchitecture = $env:PROCESSOR_ARCHITECTURE
    if ($processorArchitecture -and $processorArchitecture -eq 'ARM64') {
        $bits = 32
    }

    $processorArchiteW6432 = $env:PROCESSOR_ARCHITEW6432
    if ($processorArchiteW6432 -and $processorArchiteW6432 -eq 'ARM64') {
        $bits = 32
    }

    return $bits
}