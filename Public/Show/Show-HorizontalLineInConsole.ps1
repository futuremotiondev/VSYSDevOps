using module "..\..\Completions\Completers.psm1"
using namespace Spectre.Console
function Show-HorizontalLineInConsole {
    param (

        [string] $RuleCharacter = "─",

        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $ForeColor="White",

        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $BackColor="Black"
    )

    $CSplat = @{ ForegroundColor = $ForeColor; BackgroundColor = $BackColor }

    $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
    $Width = (-not($ConsoleWidth)) ? '80' : ($ConsoleWidth - 1)

    Write-SpectreHost "[$ForeColor]$($RuleCharacter * $Width)[/]"
}