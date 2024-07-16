function Format-Milliseconds {
    [CmdletBinding(DefaultParameterSetName = "PrecisionDecimal")]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, [int32]::MaxValue)]
        [Int32] $Milliseconds,

        [Parameter(Mandatory=$false)]
        [ValidateSet('All', 'Days', 'Hours', 'Minutes', 'Seconds', IgnoreCase=$true)]
        [string] $ConvertTo = 'All',

        [Parameter(Mandatory=$false, ParameterSetName="PrecisionDecimal")]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DecimalPlaces = 2,

        [Parameter(Mandatory=$false, ParameterSetName="PrecisionSignificant")]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $SignificantFigures = 4
    )

    [timespan]$ts = [timespan]::FromMilliseconds($Milliseconds)
    $fOp = "F$DecimalPlaces"
    if($PSCmdlet.ParameterSetName -eq 'PrecisionSignificant'){
        $fOp = "G$SignificantFigures"
    }

    switch ($ConvertTo) {
        'Days' {
            return ($ts.TotalDays).ToString($fOp)
        }
        'Hours' {
            return ($ts.TotalHours).ToString($fOp)
        }
        'Minutes' {
            return ($ts.TotalMinutes).ToString($fOp)
        }
        'Seconds' {
            return ($ts.TotalSeconds).ToString($fOp)
        }
        'All' {
            $returnHash = [ordered]@{
                Days = $ts.Days
                Hours = $ts.Hours
                Minutes = $ts.Minutes
                Seconds = $ts.Seconds
                Milliseconds = $ts.Milliseconds
            }
            return $returnHash
        }
    }
}

