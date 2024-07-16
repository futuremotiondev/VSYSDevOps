function Convert-iTermColorsToINI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List += $P }
            elseif ($P.Path) { $List += $P.Path }
            elseif ($P.FullName) { $List += $P.FullName }
            elseif ($P.PSPath) { $List += $P.PSPath }
            else { Write-Warning "$P is an unsupported type." }
        }
    }

    end {
        $List | ForEach-Object -Parallel {

            $Source = $_

            $finalOutput = @{}

            [xml]$xmlObj = [xml](Get-Content $Source)

            $keysArray = @($xmlObj.plist.dict.key)
            $valuesArray = @($xmlObj.plist.dict.dict)
            $hexColorsArray = foreach ($value in $valuesArray) {

                [float[]]$Real = $value.real

                [int]$B = $Real[0] * 255
                [int]$G = $Real[1] * 255
                [int]$R = $Real[2] * 255

                "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B
            }

            $winColorNamesArray = foreach ($key in $keysArray) {
                $iTermColor = $key
                $colorMappings = @{
                    "Ansi 0 Color"        = "black"
                    "Ansi 1 Color"        = "red"
                    "Ansi 2 Color"        = "green"
                    "Ansi 3 Color"        = "yellow"
                    "Ansi 4 Color"        = "blue"
                    "Ansi 5 Color"        = "purple" # I can't find magenta in the VSCode colors, so I go with purple
                    "Ansi 6 Color"        = "cyan"
                    "Ansi 7 Color"        = "white"
                    "Ansi 8 Color"        = "brightBlack"
                    "Ansi 9 Color"        = "brightRed"
                    "Ansi 10 Color"       = "brightGreen"
                    "Ansi 11 Color"       = "brightYellow"
                    "Ansi 12 Color"       = "brightBlue"
                    "Ansi 13 Color"       = "brightPurple"
                    "Ansi 14 Color"       = "brightCyan"
                    "Ansi 15 Color"       = "brightWhite"
                    "Cursor Color"        = "cursorColor"
                    "Selection Color"     = "selectionBackground"
                    "Background Color"    = "background"
                    "Foreground Color"    = "foreground"
                }
                $colorMappings.$iTermColor
            }

            Write-Host "`$winColorNamesArray:" $winColorNamesArray -ForegroundColor Green

            for ($i = 0; $i -lt $winColorNamesArray.Length; $i++) {
                if ($winColorNamesArray[$i] -notmatch "^!") {
                    $finalOutput[$winColorNamesArray[$i]] = $hexColorsArray[$i]
                }
            }

            $finalOutput['name'] = [System.IO.Path]::GetFileNameWithoutExtension($_).Trim()

            $JSONOut = $finalOutput | ConvertTo-Json

            $DestDir = [IO.Path]::GetDirectoryName($Source)
            $DestBase = $(Split-Path -Path $Source -LeafBase) + ".ini"
            $DestFile = Join-Path $DestDir $DestBase

            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = $DestFile.Substring(0, $DestFile.LastIndexOf('.'))
            $FileExtension  = [System.IO.Path]::GetExtension($DestFile)
            while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            $JSONOut | Out-File -LiteralPath $DestFile -Force


        } -ThrottleLimit $MaxThreads
    }
}