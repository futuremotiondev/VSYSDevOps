function Stop-PwshProcesses {
    Get-Process -Name hideexec* | Stop-Process -Force
    Get-Process -Name pwsh* | Stop-Process -Force
}