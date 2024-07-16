function Format-Bytes {
    [CmdletBinding(DefaultParameterSetName = 'AutoSuffixes')]
    param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ParameterSetName = 'AutoSuffixes')]
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ParameterSetName = 'OverrideIndividualSuffixes')]
        [ValidateNotNullOrEmpty()]
        [Float] $Bytes,

        [Parameter(ParameterSetName='AutoSuffixes',ValueFromPipelineByPropertyName)]
        [Switch] $LongSuffixes,

        [Parameter(ParameterSetName='AutoSuffixes',ValueFromPipelineByPropertyName)]
        [Switch] $ShortSuffixes,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideBytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideKilobytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideMegabytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideGigabytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideTerrabytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverridePetabytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideExabytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideZettabytesSuffix = $null,

        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [String] $OverrideYottabytesSuffix = $null,

        [Parameter(ParameterSetName='AutoSuffixes')]
        [Parameter(ParameterSetName='OverrideIndividualSuffixes')]
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Int32] $DecmialPlaces = 2

    )

    process {

        if (([String]::IsNullOrEmpty($Bytes)) -or [String]::IsNullOrWhiteSpace($Bytes)) {
            throw "Value passed to -Bytes is invalid"
        }

        $Base = 1024  # Base2: 1024, Base10: 1000
        $Unit = [math]::floor( [math]::log($Bytes) / [math]::log($Base) )
        $Bytes = $Bytes / [math]::pow($Base, $Unit)

        [Array]$LSuffixes = ( "Bytes", "Kilobytes", "Megabytes",
            "Gigabytes", "Terrabytes", "Petabytes",
            "Exabytes", "Zettabytes", "Yottabytes" )
        [Array]$SSuffixes = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
        [Array]$SuffixesToUse = $SSuffixes

        switch ($PsCmdlet.ParameterSetName) {
            "AutoSuffixes" {
                if ($LongSuffixes) {
                    [Array]$SuffixesToUse = $LSuffixes
                } else {
                    [Array]$SuffixesToUse = $SSuffixes
                }
            }
            "OverrideIndividualSuffixes" {
                $StartingSuffixes = $SSuffixes
                if (-not([String]::IsNullOrWhiteSpace($OverrideBytesSuffix))) { $StartingSuffixes[0] = $OverrideBytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideKilobytesSuffix))) { $StartingSuffixes[1] = $OverrideKilobytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideMegabytesSuffix))) { $StartingSuffixes[2] = $OverrideMegabytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideGigabytesSuffix))) { $StartingSuffixes[3] = $OverrideGigabytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideTerrabytesSuffix))) { $StartingSuffixes[4] = $OverrideTerrabytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverridePetabytesSuffix))) { $StartingSuffixes[5] = $OverridePetabytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideExabytesSuffix))) { $StartingSuffixes[6] = $OverrideExabytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideZettabytesSuffix))) { $StartingSuffixes[7] = $OverrideZettabytesSuffix }
                if (-not([String]::IsNullOrWhiteSpace($OverrideYottabytesSuffix))) { $StartingSuffixes[8] = $OverrideYottabytesSuffix }
                $SuffixesToUse = $StartingSuffixes
            }
        }

        "{0:N$DecmialPlaces} {1}" -f $Bytes, $SuffixesToUse[$Unit]
    }


}

# Format-Bytes -Bytes 12314135