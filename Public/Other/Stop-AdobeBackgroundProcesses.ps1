function Stop-AdobeBackgroundProcesses {
    Get-Process * | Where-Object {($_.CompanyName -match "Adobe" -or $_.Path -match "Adobe") `
                -and (($_.ProcessName -ne 'Photoshop') `
                -and ($_.ProcessName -ne 'Illustrator'))} `
                | Stop-Process -Force
}