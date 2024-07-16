function Format-FileSize {
    [cmdletbinding()]
    param(

        [Parameter(Mandatory, Position = 0)]
        [Double] $Value,

        [Parameter(Mandatory)]
        [validateset("Bytes", "KB", "MB", "GB", "TB", IgnoreCase = $true)]
        [String] $From,

        [Parameter(Mandatory)]
        [validateset("Bytes", "KB", "MB", "GB", "TB", IgnoreCase = $true)]
        [String] $To,

        [Int] $Precision = 4,
        [Switch] $NoLabel

    )

    switch ($From) {
        "Bytes" { $Value = $Value }
        "KB" { $Value = $Value * 1024 }
        "MB" { $Value = $Value * 1024 * 1024 }
        "GB" { $Value = $Value * 1024 * 1024 * 1024 }
        "TB" { $Value = $Value * 1024 * 1024 * 1024 * 1024 }
    }

    switch ($To) {
        "Bytes" { $Value = $Value }
        "KB" { $Value = $Value / 1KB }
        "MB" { $Value = $Value / 1MB }
        "GB" { $Value = $Value / 1GB }
        "TB" { $Value = $Value / 1TB }
    }

    if ($NoLabel) {
        [Math]::Round($Value, $Precision, [MidPointRounding]::AwayFromZero)
    }else{
        ([Math]::Round($Value, $Precision, [MidPointRounding]::AwayFromZero)).ToString() + " $To"
    }
}