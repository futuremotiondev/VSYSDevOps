function Invoke-OokiiPasswordDialog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [String]
        $MainInstruction,

        [Parameter(Mandatory=$false)]
        [String]
        $WindowTitle="Please enter a password",

        [Parameter(Mandatory=$false)]
        [Int32]
        $MaxLength=35
    )

    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Enable DPI awareness
$code = @"
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
"@
    $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
    $null = $Win32Helpers::SetProcessDPIAware()

    $IDialog                    = New-Object Ookii.Dialogs.WinForms.InputDialog
    $IDialog.MainInstruction    = $MainInstruction
    $IDialog.WindowTitle        = $WindowTitle
    $IDialog.UsePasswordMasking = $true
    $IDialog.MaxLength          = $MaxLength

    $Result = $IDialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true}))

    if($Result -eq 'OK'){
        [array] $ReturnArray = $IDialog.Input
        return (, $ReturnArray)
    }

}