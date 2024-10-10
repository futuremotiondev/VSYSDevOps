using module "..\..\Completions\Completers.psm1"
using namespace Spectre.Console

<#
.SYNOPSIS
    Displays a horizontal line in the console.

.DESCRIPTION
    The Show-HorizontalLineInConsole function displays a horizontal line across the console window.
    The character used for the line and its color can be customized.

.PARAMETER RuleCharacter
    The character to use for the horizontal line. Default is "─".

.PARAMETER ForeColor
    The color of the horizontal line. Default is "White". This parameter supports argument completions for Spectre colors.

.EXAMPLE
    PS C:\> Show-HorizontalLineInConsole

    Displays a horizontal line using the default character "─" and color "White".

.EXAMPLE
    PS C:\> Show-HorizontalLineInConsole -RuleCharacter "="

    Displays a horizontal line using the character "=" and the default color "White".

.EXAMPLE
    PS C:\> Show-HorizontalLineInConsole -ForeColor "Red"

    Displays a horizontal line using the default character "─" and the color "Red".

.NOTES
    Author: Futuremotion
    Date: 2023-10-05
    Website: https://github.com/futuremotiondev
#>
function Show-HorizontalLineInConsole {
    param (

        [string] $RuleCharacter = "─",

        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $ForeColor="White"
    )

    $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
    $Width = (-not($ConsoleWidth)) ? '80' : ($ConsoleWidth - 1)
    Write-SpectreHost "[$ForeColor]$($RuleCharacter * $Width)[/]"

}