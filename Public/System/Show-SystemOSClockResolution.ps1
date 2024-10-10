function Show-SystemOSClockResolution {
    param (
        [Parameter(Mandatory=$false)]
        [Switch] $ShowUnitLabel,

        [ValidateSet('String','Decimal', IgnoreCase = $true)]
        [String] $ReturnType = 'String',

        [Switch] $ShowTable,

        [ValidateSet('Auto','Minimum','Small','Medium','FullWidth', IgnoreCase = $true)]
        [String] $TableWidth = 'Auto'
    )


    try {
        $ClockCMD = Get-Command Clockres64.exe -CommandType Application
    } catch {
        throw "Can't find Clockres64.exe"
    }

    if($ShowUnitLabel -and $ReturnType -eq 'Decimal'){
        throw "-ShowUnitLabel is not compatible with a Decimal return type. Aborting."
    }

    $ResultStr = & $ClockCMD -split '\r\n'
    $ReturnObj = [PSCustomObject]@{ MaxInterval = ''; MinInterval = ''; CurInterval = ''; }

    foreach ($Item in $ResultStr) {
        if([String]::IsNullOrEmpty($Item)){ continue }
        $Matches = $null
        if($Item -match '(m?)^(Maximum|Minimum|Current)(:?.*):\s([\d\.]+)\s+ms$'){
            if($Matches[2] -eq 'Maximum'.Trim()){
                $ReturnObj.MaxInterval = $Matches[4].Trim() -as [String]
                if(($ReturnType -eq 'String') -and $ShowUnitLabel){
                    $ReturnObj.MaxInterval = "$($ReturnObj.MaxInterval) ms"
                }
                if($ReturnType -eq 'Decimal') {
                    $ReturnObj.MaxInterval = $ReturnObj.MaxInterval -as [decimal]
                }
            }
            if($Matches[2] -eq 'Minimum'.Trim()){
                $ReturnObj.MinInterval = $Matches[4].Trim() -as [String]
                if(($ReturnType -eq 'String') -and $ShowUnitLabel){
                    $ReturnObj.MinInterval = "$($ReturnObj.MinInterval) ms"
                }
                if($ReturnType -eq 'Decimal') {
                    $ReturnObj.MinInterval = $ReturnObj.MinInterval -as [decimal]
                }
            }
            if($Matches[2] -eq 'Current'.Trim()){
                $ReturnObj.CurInterval = $Matches[4].Trim() -as [String]
                if(($ReturnType -eq 'String') -and $ShowUnitLabel){
                    $ReturnObj.CurInterval = "$($ReturnObj.CurInterval) ms"
                }
                if($ReturnType -eq 'Decimal') {
                    $ReturnObj.CurInterval = $ReturnObj.CurInterval -as [decimal]
                }
            }
        }
    }

    if($ShowTable){

        $ConsoleWidth      = $Host.UI.RawUI.WindowSize.Width
        $TableWidthMinimum = (-not($ConsoleWidth)) ? '40' : (($ConsoleWidth - 1) / 2.7)
        $TableWidthSmall   = (-not($ConsoleWidth)) ? '70' : (($ConsoleWidth - 1) / 2.3)
        $TableWidthMedium  = (-not($ConsoleWidth)) ? '100' : (($ConsoleWidth - 1) / 1.8)
        $TableWidthFull    = (-not($ConsoleWidth)) ? '130' : ($ConsoleWidth - 1)

        $tableSplat = @{
            Border = 'Rounded'
            Color = '#5f6266'
            HeaderColor = '#f1f4f7'
            TextColor = '#abb4bf'
            AllowMarkup = $true
        }

        if($TableWidth -ne 'Auto'){
            $tableSplat['width'] = switch ($TableWidth) {
                "Minimum"   {$TableWidthMinimum}
                "Small"	    {$TableWidthSmall}
                "Medium"	{$TableWidthMedium}
                "FullWidth"	{$TableWidthFull}
            }
        }

        $ReturnObj | Format-SpectreTable @tableSplat
    }
    else {
        $ReturnObj
    }
}