function Start-CountdownTimer {

    param (

        [Parameter(Position=0)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]$Seconds = 0,

        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]$Milliseconds = 0,

        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]$Minutes = 0,

        [ValidateSet('Milliseconds',
                     'Seconds','SecondsDecimal','SecondsAndMilliseconds',
                     'MinutesDecimal','MinutesAndSeconds',
                     'MinutesAndSecondsAndMilliseconds',
                     IgnoreCase = $true
        )]
        [String] $CountdownUnit = 'Seconds',
        [String] $FormatString = "Starting in [%TIME%]s...",
        [String] $FormatSeparator = ':',
        [Switch] $ShowSpinner
    )

    if(($Seconds + $Milliseconds + $Minutes) -eq 0){
        throw "You must pass in a value to either -Seconds -Milliseconds or -Minutes"
    }

    $spinner = @('|', '/', '-', '\')
    $spinnerPos = 0
    $origpos = $host.UI.RawUI.CursorPosition
    [Console]::CursorVisible = $false
    $totalMilliseconds = ($Minutes * 60000) + ($Seconds * 1000) + $Milliseconds
    $runTime = $totalMilliseconds

    try {
        while($runTime -gt 0) {
            switch ($CountdownUnit) {
                'Milliseconds' {
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', "${runTime}"
                }
                'SecondsDecimal' {
                    $sec = Format-Milliseconds -Milliseconds $runTime -ConvertTo Seconds -DecimalPlaces 2
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', ('{0}' -f $sec)
                }
                'SecondsAndMilliseconds' {
                    $sec = [math]::Floor($runTime / 1000) -as [System.Int32]
                    $mil = $runTime % 1000
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', ("{0:D2}$FormatSeparator{1:D3}" -f $sec, $mil)
                }
                'MinutesDecimal' {
                    $min = Format-Milliseconds -Milliseconds $runTime -ConvertTo Minutes -DecimalPlaces 2
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', ('{0}' -f $min)
                }
                'MinutesAndSeconds' {
                    $min = [math]::Floor($runTime / 60000) -as [System.Int32]
                    $sec = [math]::Floor(($runTime % 60000) / 1000) -as [System.Int32]
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', ("{0:D2}$FormatSeparator{1:D2}" -f $min, $sec)
                }
                'MinutesAndSecondsAndMilliseconds' {
                    $min = [math]::Floor($runTime / 60000) -as [System.Int32]
                    $sec = [math]::Floor(($runTime % 60000) / 1000) -as [System.Int32]
                    $mil = $runTime % 1000
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', ("{0:D2}$FormatSeparator{1:D2}$FormatSeparator{2:D3}" -f $min, $sec, $mil)
                }
                default {
                    $remainingSeconds = [math]::Round($runTime / 1000, 2) -as [System.Int32]
                    $FormatStringNow = $FormatString -replace '\[%TIME%\]', "${remainingSeconds}"
                }
            }

            if($ShowSpinner){
                Write-Host (" {0} " -f $spinner[$spinnerPos%4]) -NoNewline
                Write-Host $FormatStringNow -NoNewline
            }else{
                Write-Host $FormatStringNow -NoNewline
            }

            $host.UI.RawUI.CursorPosition = $origpos
            $spinnerPos += 1

            if(($CountdownUnit -match 'Milliseconds') -or ($CountdownUnit -match 'SecondsDecimal')){
                $runTime -= 50 # Decrement by 50 milliseconds for more granular countdown display
                Start-Sleep -Milliseconds 50
            } else {
                $runTime -= 1000 # Decrement by 1000 milliseconds (1 second)
                Start-Sleep -Milliseconds 1000
            }
        }
    } finally {
        Write-Host "" -NoNewline
        [Console]::CursorVisible = $true
    }
}