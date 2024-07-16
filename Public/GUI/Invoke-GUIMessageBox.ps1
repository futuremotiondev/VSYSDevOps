using namespace System.Windows.Forms
using namespace System.Drawing

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')    | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')   | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null

function Invoke-GUIMessageBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $Message,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName)]
        [String]
        $Title="Notification",

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName)]
        [ValidateSet('AbortRetryIgnore', 'CancelTryContinue', 'OK', 'OKCancel', 'RetryCancel', 'YesNo', 'YesNoCancel', IgnoreCase = $true)]
        [String]
        $Buttons='OKCancel',

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Error', 'Question', 'Warning', 'Information', IgnoreCase = $true)]
        [String]
        $Icon='Information',

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName)]
        [ValidateSet('Button1', 'Button2', 'Button3', 'Button4', IgnoreCase = $true)]
        [String]
        $DefaultButton='Button1'
    )

    Begin {
        #Enable visual styles


        #Enable DPI awareness
$code = @"
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
"@
        $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
        $null = $Win32Helpers::SetProcessDPIAware()
    }

    Process {
        [Application]::EnableVisualStyles()
        $Result = [System.Windows.Forms.MessageBox]::Show($this, $Message, $Title, $Buttons, $Icon, $DefaultButton)
        $Result
    }

    End {

    }
}