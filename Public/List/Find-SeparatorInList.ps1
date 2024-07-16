using namespace System.Text.RegularExpressions

function Find-SeparatorInList {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $InputText,
        [Switch] $IncludeDot,
        [Switch] $InputIsFileList
    )

    process {
        $InputText = $InputText.Trim()
        $reDelimiters = @{
            Tab = '\t'
            Pipe = '\|'
        }
        if (-not $InputIsFileList) {
            if ($IncludeDot) {
                $reDelimiters["Dot"] = '\.'
            }
            $reDelimiters["Comma"] = '\,'
            $reDelimiters["Semicolon"] = ';'
            $reDelimiters["Colon"] = '\:'
        }

        $reOps = [RegexOptions]::IgnoreCase -bor [RegexOptions]::Compiled
        $maxCount = 1
        $bestDelimiter = $null
        $bestDelimiterRegex = $null
        $delimiterFound = $false
        $bestGuess = $null

        foreach ($delim in $reDelimiters.GetEnumerator()) {
            $re = [regex]::new($delim.Value, $reOps)
            $parts = $re.Split($InputText)
            if ($parts.Count -gt $maxCount) {
                $maxCount = $parts.Count
                $bestDelimiter = $delim.Key
                $bestDelimiterRegex = $delim.Value
                $bestDelimiterValue = $delim.Value -replace '^\\', ''
                $delimiterFound = $true
                $bestGuess = $delim.Key
            }
        }

        $crlfCount = ([regex]::Matches($InputText, "\r\n")).Count
        $lfCount = ([regex]::Matches($InputText, "\n")).Count
        $newlineType = $null
        $linebreaksPresent = $false
        $linebreaksMalformed = $false

        if ($crlfCount -gt 0 -or $lfCount -gt 0) {
            $linebreaksPresent = $true
            $newlineType = $crlfCount -ge $lfCount ? "\r\n" : "\n"
            $newlineLabel = $newlineType -eq "\r\n" ? "CRLF" : "LF"
            $newlineCount = $newlineType -eq "\r\n" ? $crlfCount : $lfCount
            if (!$delimiterFound){
                $delimiterFound = $true
                $bestDelimiter = $newlineLabel
                $bestDelimiterRegex = $newlineType
                $bestDelimiterValue = $newlineType
                $bestGuess = $bestDelimiter
            }else{

                $delimiterNewlineCount = ([regex]::Matches($InputText, "$bestDelimiterRegex$newlineType")).Count
                $delimCount = $maxCount - 1

                if ($delimCount -ne $newlineCount) {
                    $delimiterFound = $false
                    $linebreaksMalformed = $true
                    $bestDelimiter = $null
                    $bestDelimiterValue = $null
                    $bestDelimiterRegex = $null
                } else {
                    $delimiterFound = $true
                    $bestDelimiter = "${bestDelimiter}+${newlineLabel}"
                    $bestDelimiterValue = "${bestDelimiterValue}${newlineType}"
                    $bestDelimiterRegex = "${bestDelimiterRegex}${newlineType}"
                    $bestGuess = $bestDelimiter
                }
            }
        }

        [PSCustomObject]@{
            DelimiterFound      =  $delimiterFound
            DelimiterName       =  $bestDelimiter
            Delimiter           =  $bestDelimiterValue
            DelimiterRegEx      =  $bestDelimiterRegex
            BestGuess           =  $bestGuess
            LinebreaksPresent   =  $linebreaksPresent
            LinebreaksMalformed =  $linebreaksMalformed
        }
    }
}


# $testString1 = "dllhost_SEDW0vuH15.png, firefox_6kICy5qp3T.png, Code_QUGLtN0NkX.png, apple, Medical Cross, Anatomical Heart"
# $testString2 =
# "
# Common7\Tools\api-ms-win-crt-convert-l1-1-0.dll,
# Common7\Tools\api-ms-win-crt-filesystem-l1-1-0.dll,
# Common7\Tools\errlook.exe,
# Common7\Tools\errlook.hlp,
# Common7\Tools\guidgen.exe,
# Common7\Tools\Launch-VsDevShell.ps1,
# Common7\Tools\LaunchDevCmd.bat,
# Common7\Tools\makehm.exe,
# Common7\Tools\mfc140chs.dll,
# Common7\Tools\mfc140cht.dll
# "
# $testString3 = "dllhost_SEDW0vuH15.png firefox_6kICy5qp3T.png Code_QUGLtN0NkX.png apple Medical Cross Anatomical Heart"
# $testString4 = "dllhost_SEDW0vuH15.png | firefox_6kICy5qp3T.png | Code_QUGLtN0NkX.png | apple Medical Cross Anatomical Heart"
# $testString5 = "dllhost_SEDW0vuH15.png |
# firefox_6kICy5qp3T.png | Code_QUGLtN0NkX.png | apple Medical Cross Anatomical Heart"
# $testString6 = "D:/Dev/VSCode/Projects/snippets/powershell/fm-pwsh-snippets
# C:/Icons/Brands/SVG/Brands Dev/Sorted/Powershell
# D:/Design/Stock/Vector/Branding Starters/UI8 CatalystUI Mega Logo Collection/00 Source/Figma
# C:/Users/futur/Desktop/Dsgn/Logos that Last/Logos that Last/OEBPS/fonts/Headers
# D:/Fonts/Licensed/Display/Futuristic UI/Architectural
# C:/Users/futur
# D:/Dev/Powershell


# "
# Find-SeparatorInList -InputText $testString1
