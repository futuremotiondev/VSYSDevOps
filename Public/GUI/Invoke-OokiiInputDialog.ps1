function Invoke-OokiiInputDialog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [String]
        $MainInstruction,

        [Parameter(Mandatory)]
        [String]
        $MainContent,

        [Parameter(Mandatory=$false)]
        [String]
        $WindowTitle="Please provide input",

        [Parameter(Mandatory=$false)]
        [String]
        $InputText="Enter your text here",

        [Parameter(Mandatory=$false)]
        [Int32]
        $MaxLength=30,

        [Parameter(Mandatory=$false)]
        [Switch]
        $UsePasswordMasking,

        [Parameter(Mandatory=$false)]
        [Switch]
        $Multiline
    )

    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Enable DPI awareness
$code = @"
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
"@
    $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
    $null = $Win32Helpers::SetProcessDPIAware()

    $IDialog                 = New-Object Ookii.Dialogs.WinForms.InputDialog
    $IDialog.MainInstruction = $MainInstruction
    $IDialog.Content         = $MainContent
    $IDialog.WindowTitle     = $WindowTitle
    $IDialog.Input           = $InputText
    $IDialog.MaxLength       = $MaxLength
    $IDialog.Multiline       = $Multiline

    if($UsePasswordMasking) {$IDialog.UsePasswordMasking = $true}

    [System.Windows.Forms.Form] $TheForm = New-Object -TypeName System.Windows.Forms.Form
    $TheForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $TheForm.TopMost = $true
    $TheForm.TopLevel = $true

    $Result = $IDialog.ShowDialog($TheForm)

    [PSCustomObject]@{
        Result = $Result
        Input = $IDialog.Input
    }
}