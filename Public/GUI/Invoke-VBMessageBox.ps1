function Invoke-VBMessageBox {

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $Message,

        [Parameter(Position = 1, Mandatory = $false)]
        [string]
        $Title = "Information",

        [Parameter(Position = 2, Mandatory = $false)]
        [ValidateSet("Information", "Question", "Critical", "Exclamation")]
        [string]
        $Icon = "Information",

        [Parameter(Position = 3, Mandatory = $false)]
        [ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")]
        [string]
        $BoxType = "OkOnly",

        [Parameter(Position = 4, Mandatory = $false)]
        [ValidateSet(1, 2, 3)]
        [int]
        $DefaultButton = 1,

        [Parameter(Position = 5, Mandatory=$false)]
        [Switch]
        $NonTopMost
    )

    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Enable DPI awareness
$code = @"
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
"@
    $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
    $null = $Win32Helpers::SetProcessDPIAware()


    switch ($Icon) {
        "Question"          { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Question }
        "Critical"          { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Critical }
        "Exclamation"       { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Exclamation }
        "Information"       { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Information }
    }

    switch ($BoxType) {
        "OKOnly"            { $vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly }
        "OKCancel"          { $vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel }
        "AbortRetryIgnore"  { $vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore }
        "YesNoCancel"       { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel }
        "YesNo"             { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo }
        "RetryCancel"       { $vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel }
    }

    switch ($Defaultbutton) {
        1 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1 }
        2 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2 }
        3 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3 }
    }

    if($NonTopMost) {
        $vb_systemmodal = ''
    }else{
        $vb_systemmodal = [microsoft.visualbasic.msgboxstyle]::SystemModal
    }

    $popuptype = $vb_icon -bor $vb_box -bor $vb_systemmodal -bor $vb_defaultbutton
    $ans = [Microsoft.VisualBasic.Interaction]::MsgBox($Message, $popuptype, $title)
    return $ans

}