function Stop-AdobeProcesses {

    Get-Process -Name Adobe* | Stop-Process -Force
    Get-Process -Name CCLibrary | Stop-Process -Force
    Get-Process -Name CCXProcess | Stop-Process -Force
    Get-Process -Name CoreSync | Stop-Process -Force
    Get-Process -Name AdobeIPCBroker | Stop-Process -Force
    Get-Process -Name Adobe CEF Helper | Stop-Process -Force

}