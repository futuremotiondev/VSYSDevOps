function Invoke-OokiiTaskDialog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=0)]
        [String]
        $MainInstruction="Please select an option",

        [Parameter(Mandatory=$false)]
        [String]
        $MainContent="Laboris labore magna amet irure deserunt dolore non dolore duis est enim laboris. Ea irure pariatur deserunt reprehenderit.",

        [Parameter(Mandatory=$false)]
        [Collections.ArrayList]
        $MainButtons,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Standard','CommandLinks','CommandLinksNoIcon', IgnoreCase = $true)]
        [String]
        $MainButtonStyle="CommandLinks",

        [Parameter(Mandatory=$false)]
        [ValidateSet('Warning','Error','Information', 'Shield', IgnoreCase = $true)]
        [String]
        $MainIcon="Information",

        [Parameter(Mandatory=$false)]
        [String]
        $WindowTitle="Please select an option",

        [Parameter(Mandatory=$false)]
        [String]
        $FooterText="This is predefined footer text for this TaskDialog. <a href=`"https://www.stackoverflow.com`">stackoverflow.com</a>",

        [Parameter(Mandatory=$false)]
        [ValidateSet('Warning','Error','Information', "Shield", IgnoreCase = $true)]
        $FooterIcon="Information",

        [Parameter(Mandatory=$false)]
        [String]
        $CustomFooterIcon,

        [Parameter(Mandatory=$false)]
        [switch]
        $DisableFooterHyperlinks,

        [Parameter(Mandatory=$false)]
        [String]
        $ExpandedInfo="Additional related or expanded information goes here.",

        [Parameter(Mandatory=$false)]
        [switch]
        $ExpandedInfoOpenByDefault,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Top','Bottom',IgnoreCase = $true)]
        [String]
        $ExpandedInfoPosition="Bottom",

        [Parameter(Mandatory=$false)]
        [String]
        $ExpandedText="Hide additional information",

        [Parameter(Mandatory=$false)]
        [String]
        $CollapsedText="Show additional information",

        [Parameter(Mandatory=$false)]
        [switch]
        $Modal,

        [Parameter(Mandatory=$false)]
        [String]
        $CustomWindowFormIcon,

        [Parameter(Mandatory=$false)]
        [Int32]
        $DialogWidth=0,

        [Parameter(Mandatory=$false)]
        [switch]
        $ShowMinimize,

        [Parameter(Mandatory=$false)]
        [switch]
        $AllowCancel
    )

    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Enable DPI awareness
$code = @"
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
"@
    $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
    $null = $Win32Helpers::SetProcessDPIAware()

    # Define additional custom icons for use with $MainIcon

    # Helper function to check whether a passed
    # Icon path actually points to a valid .ico file.
    $CheckValidICO = {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [String]
            $IcoPath
        )

        $result = $false
        if($IcoPath){
            if(Test-Path -LiteralPath $IcoPath -PathType Leaf){
                $ext = [IO.Path]::GetExtension($IcoPath)
                if($ext -eq '.ico'){
                    $result = $true
                }
            }
        }
        $result
    }

    $MainDialog = New-Object Ookii.Dialogs.WinForms.TaskDialog

    if($MainButtons) { $MainButtons = $MainButtons.Clone() }

    if(($MainButtons).Length -eq 0){

        $ContinueBtn = [Ookii.Dialogs.WinForms.TaskDialogButton]::New("Continue")
        $ContinueBtn.CommandLinkNote = "Proceed with new changes"
        $ContinueBtn.ElevationRequired = $true

        $CancelButton = [Ookii.Dialogs.WinForms.TaskDialogButton]::New("Cancel")
        $CancelButton.CommandLinkNote = "Cancel all current changes"
        $CancelButton.Default = $true

        $MainDialog.Buttons.Add($ContinueBtn)
        $MainDialog.Buttons.Add($CancelButton)

    }else{
        foreach ($Btn in $MainButtons) {
            $MainDialog.Buttons.Add($Btn)
        }
    }

    $MainDialog.MainInstruction         = $MainInstruction
    $MainDialog.Content                 = $MainContent
    $MainDialog.ButtonStyle             = $MainButtonStyle
    $MainDialog.ExpandedInformation     = $ExpandedInfo
    $MainDialog.ExpandedByDefault       = $ExpandedInfoOpenByDefault
    $MainDialog.CollapsedControlText    = $CollapsedText
    $MainDialog.ExpandedControlText     = $ExpandedText
    $MainDialog.MinimizeBox             = $ShowMinimize
    $MainDialog.Width                   = $DialogWidth
    $MainDialog.AllowDialogCancellation = $AllowCancel
    $MainDialog.WindowTitle             = $WindowTitle

    $MainDialog.ExpandFooterArea = if($ExpandedInfoPosition -eq 'Top') { $false } else { $true }
    $MainDialog.MainIcon = $MainIcon

    if($FooterText) { $MainDialog.Footer = $FooterText}

    if($DisableFooterHyperlinks) {
        $MainDialog.EnableHyperlinks = $false
    }else{
        $MainDialog.EnableHyperlinks = $true
        $MainDialog.add_HyperlinkClicked({
            Start-Process $_.href
        })
    }

    if($CustomFooterIcon) { $IsValidFooterIco = & $CheckValidICO $CustomFooterIcon }
    if($IsValidFooterIco){
        $MainDialog.FooterIcon = ""
        $MainDialog.FooterIcon = $CustomFooterIcon
    }else{
        $MainDialog.FooterIcon = $FooterIcon
    }

    $DefaultWindowIconB64 = 'AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAMMOAADDDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAISEhpyEhIb8hISG/ISEhvyEhIb8hISG/ISEhvyEhIb8hISG/ISEhvyEhIb8hISG/ISEhvyEhIb8hISG/ISEhpyEhIb8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIb8hISG/ISEh/x4eHhkeHh4ZHh4eGR4eHhkhISH/Hh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGSEhIf8hISG/ISEhvyEhIf8eHh4ZHh4eGR4eHhkeHh4ZISEh/x4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkhISH/ISEhvyEhIb8hISH/Hh4eGR4eHhkeHh4ZHh4eGSEhIf8eHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZISEh/yEhIb8hISG/ISEh/x4eHhkeHh4ZHh4eGR4eHhkhISH/Hh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGSEhIf8hISG/ISEhvyEhIf8eHh4ZHh4eGR4eHhkeHh4ZISEh/x4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkhISH/ISEhvyEhIb8hISH/Hh4eGR4eHhkeHh4ZHh4eGSEhIf8eHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZISEh/yEhIb8hISG/ISEh/x4eHhkeHh4ZHh4eGR4eHhkhISH/Hh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGSEhIf8hISG/ISEhvyEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEhvyEhIb8hISH/Hh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZISEh/yEhIb8hISG/ISEh/x4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGR4eHhkeHh4ZHh4eGSEhIf8hISG/ISEhvyEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEh/yEhIf8hISH/ISEhvyEhIachISG/ISEhvyEhIb8hISG/ISEhvyEhIb8hISG/ISEhvyEhIb8hISG/ISEhvyEhIb8hISG/ISEhvyEhIacAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//8AAA=='
    $DefaultWindowIconMemoryStream = [System.IO.MemoryStream]::New([System.Convert]::FromBase64String($DefaultWindowIconB64))
    $DefaultWindowIcon = [System.Drawing.Icon]::New($DefaultWindowIconMemoryStream)

    if($Modal) {
        $Result = $MainDialog.ShowDialog()
    }else{
        if($CustomWindowFormIcon){
            $IsValidFormIco = & $CheckValidICO $CustomWindowFormIcon
            if($IsValidFormIco){
                $MainDialog.WindowIcon = $CustomWindowFormIcon
            }
        }
        else {
            $MainDialog.WindowIcon = $DefaultWindowIcon
        }
        $Result = $MainDialog.Show()
    }
    $Result
}