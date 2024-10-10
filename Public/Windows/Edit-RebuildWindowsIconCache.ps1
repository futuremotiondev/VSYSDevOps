function Edit-RebuildWindowsIconCache {

    [CmdletBinding()]
    param ()

    $ThumbCacheArray = @(
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_16.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_16.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_32.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_32.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_48.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_48.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_96.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_256.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_256.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_768.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_1280.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_1920.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_2560.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_custom_stream.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_exif.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_idx.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_idx.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_sr.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_wide_alternate.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\iconcache_wide.db.backup",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_16.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_32.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_48.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_96.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_256.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_768.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_1280.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_1920.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_2560.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_custom_stream.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_exif.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_idx.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_sr.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_wide_alternate.db",
        "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\thumbcache_wide.db",
        "C:\Users\futur\AppData\Local\IconCache.db",
        "C:\Users\futur\AppData\Local\IconCache.db.backup"
    )

    $LockHunterCMD = Get-Command "C:\Program Files\LockHunter\LockHunter.exe" -CommandType Application

    [Array] $oWindows = Get-WindowsOpenDirectories

    $EverythingServiceWasRunning = $false
    $EverythingService = Get-Service -Name 'Everything (1.5a)'
    if($EverythingService.Status -eq 'Running'){
        $EverythingServiceWasRunning = $true
        Stop-Service -Name 'Everything (1.5a)' -Force
    }

    $EverythingProcessWasRunning = $false
    $EverythingProcess = Get-Process -Name Everything64 -ErrorAction SilentlyContinue
    if(-not($EverythingProcess)){
        Write-Host "Everything is not running." -f Gray
    }
    else {
        $EverythingProcessWasRunning = $true
        Stop-Process -Name Everything64 -Force
    }

    $RuntimeBrokerServiceWasRunning = $false
    $RuntimeBrokerService = Get-Service -Name TimeBrokerSvc
    if($RuntimeBrokerService.Status -eq 'Running'){
        $RuntimeBrokerServiceWasRunning = $true
        gsudo { Stop-Service -Name TimeBrokerSvc -Force }
        Invoke-Expression "taskkill /f /im RuntimeBroker.exe" -ErrorAction SilentlyContinue
    }

    Invoke-Expression "taskkill /f /im df64.exe"
    Invoke-Expression "taskkill /f /im df.exe"
    Invoke-Expression "taskkill /f /im explorer.exe"

    Start-Sleep -Milliseconds 1000

    foreach($CacheFile in $ThumbCacheArray){
        Write-Host -f Gray "Deleting $CacheFile..."
        $Params = '/silent', '/exit', '/delete', $CacheFile
        & $LockHunterCMD $Params
        Start-Sleep -Milliseconds 100
    }

    Write-Host ""
    Write-Host -f Red "Cache files have been removed."
    Write-Host ""
    Write-Host -f Red "Removing IconCacheToDelete and ThumbCacheToDelete folder remnants."
    Write-Host ""

    $BackupParams1 = '/silent', '/exit', '/delete', "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\IconCacheToDelete"
    $BackupParams2 = '/silent', '/exit', '/delete', "C:\Users\futur\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete"
    & $LockHunterCMD $BackupParams1
    Start-Sleep -Milliseconds 100
    & $LockHunterCMD $BackupParams2

    Start-Sleep -Milliseconds 500
    Write-Host -f Gray "Restarting Explorer"
    Invoke-Expression "start explorer.exe" | Out-Null

    Start-Sleep -Milliseconds 800
    Write-Host -f Gray "Restarting Direct Folders"
    $cmd = 'start "" "C:\Program Files\Direct Folders\df.exe"'
    Start-Process 'cmd' -ArgumentList "/c $cmd"

    if($EverythingServiceWasRunning){
        Start-Sleep -Milliseconds 800
        Write-Host -f Gray "Restarting Everything Service"
        Start-Service -Name 'Everything (1.5a)'
    }
    if($EverythingProcessWasRunning){
        Write-Host -f Gray "Restarting Everything Process"
        $cmd = 'start "" "C:\Program Files\Everything 1.5a\Everything64.exe"'
        Start-Process 'cmd' -ArgumentList "/c $cmd" -WindowStyle Minimized
    }
    if($RuntimeBrokerServiceWasRunning){
        Write-Host -f Gray "Restarting TimeBrokerSvc Service (RuntimeBroker.exe)"
        Start-Service -Name TimeBrokerSvc
    }

    Start-Sleep -Milliseconds 200
    Write-Host -f Green "Restoring Previously Open Explorer Windows."
    foreach ($path in $oWindows) {
        Write-Host -f Gray "Opening $path"
        Start-Sleep -Milliseconds 200
        Open-WindowsExplorerTo -LiteralPath $path -Minimized
    }
}