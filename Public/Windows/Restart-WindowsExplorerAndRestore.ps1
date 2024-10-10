function Restart-WindowsExplorerAndRestore {

    [CmdletBinding()]
    param (
        [Switch] $ShowProgress
    )

    [Array] $oWindows = Get-WindowsOpenDirectories

    Invoke-Expression "taskkill /f /im df64.exe"
    Invoke-Expression "taskkill /f /im df.exe"
    Invoke-Expression "taskkill /im explorer.exe /f"
    if ($ShowProgress) {
        Write-SpectreHost -Message "[#FFFFFF]Killed[/] [#A8E9D9]Direct Folders[/] and [#A8E9D9]Explorer[/] "
    }

    Invoke-Expression "start explorer.exe" | Out-Null
    if ($ShowProgress) {
        Write-SpectreHost -Message "[#FFFFFF]Restarted[/] [#A8E9D9]Explorer[/] "
        Show-CountdownTimer -Seconds 1 -CountdownUnit SecondsDecimal -FormatString "Restarting Direct Folders in [%TIME%]s"
    }else{
        Start-Sleep -Seconds 1
    }

    $DirectFoldersUserInstall = "C:\Users\futur\AppData\Local\Programs\Direct Folders\df.exe"
    $DirectFoldersMachineInstall = "C:\Program Files\Direct Folders\df.exe"
    if(Test-Path $DirectFoldersUserInstall -PathType Leaf){
        $cmd = 'start "" "C:\Users\futur\AppData\Local\Programs\Direct Folders\df.exe"'
        Start-Process 'cmd' -ArgumentList "/c $cmd"
    }
    elseif(Test-Path $DirectFoldersMachineInstall -PathType Leaf){
        $cmd = 'start "" "C:\Program Files\Direct Folders\df.exe"'
        Start-Process 'cmd' -ArgumentList "/c $cmd"
    }

    if ($ShowProgress) {
        Write-Host ""
        Show-CountdownTimer -Milliseconds 200 -CountdownUnit Milliseconds -FormatString "Re-Opening windows in [%TIME%]ms"
        Write-Host ""
    }else{
        Start-Sleep -Milliseconds 200
    }
    foreach ($path in $oWindows) {
        if ($ShowProgress) {
            Write-SpectreHost -Message "[#FFFFFF]Re-Opening[/] [#ecb8ae]$path[/]"
            Show-CountdownTimer -Milliseconds 200 -CountdownUnit Milliseconds -FormatString "[%TIME%]ms"
        }else{
            Start-Sleep -Milliseconds 200
        }
        Open-WindowsExplorerTo -LiteralPath $path -Minimized
    }
}