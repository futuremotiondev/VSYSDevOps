function Format-ObjectSortNumerical {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object[]] $InputObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(2, 100)]
        [Byte] $MaximumDigitCount = 50,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Switch] $Descending

    )

    begin {

        $InnerInputObject = [System.Collections.Generic.List[Object]]@()
    }

    process {
        $InputObject | ForEach-Object {
            $InnerInputObject.Add($_)
        }
    }

    end {
        $InnerInputObject | Sort-Object -Property `
        @{  Expression = {
                [Regex]::Replace($_, '(\d+)', { "{0:D$MaximumDigitCount}" -f [Int16] $Args[0].Value })
            }
        },
        @{ Expression = { $_ } } -Descending:$Descending
    }
}


# $DummyArray = @(
#     "Obsidian1.png",
#     "Duet Alerts 2.png",
#     "Onterio-Spacing-Margins.png",
#     "C:\Icons\SVG\00 Sets Symbolic\Phosphor Icons v2.0.0\Bold\Phosphor Bold Align Bottom Simple.svg"
#     "C:\Icons\SVG\00 Sets Symbolic\Phosphor Icons v2.0.0\Bold\Phosphor Bold Arrow Elbow Left Up.svg"
#     "C:\Icons\SVG\00 Sets Symbolic\Phosphor Icons v2.0.0\Bold\Phosphor Bold Arrows In Line Vertical.svg"
#     "C:\Users\futur\AppData\Roaming\FirefoxDL\SVGREPO Companies 24px\XAbstract.svg",
#     "C:\Users\futur\AppData\Roaming\FirefoxDL\SVGREPO Companies 24px\Academia.svg",
#     "C:\Users\futur\AppData\Roaming\FirefoxDL\SVGREPO Companies 24px\ZAccusoft.svg",
#     "C:\Users\futur\AppData\Roaming\FirefoxDL\SVGREPO Companies 24px\1Acm.svg",
#     "C:\Users\futur\AppData\Roaming\FirefoxDL\SVGREPO Companies 24px\4Actigraph.svg",
#     "C:\Users\futur\AppData\Roaming\FirefoxDL\SVGREPO Companies 24px\20Activision.svg"
# )

# Format-ObjectSortNumerical -InputObject $OutputArray