


function Invoke-OpenFolderDialog {

    param(

        [Parameter(Mandatory=$false, Position = 0)]
        [ValidateScript({Test-Path -LiteralPath $_})]
        [string]
        $Path = [Environment]::GetFolderPath("Desktop").TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar,

        [System.Environment+SpecialFolder]
        [Parameter(Mandatory=$false)]
        [string]
        $SpecialPath,

        [Parameter(Mandatory=$false)]
        [string]
        $Title = "Select a folder",

        [Parameter(Mandatory=$false)]
        [switch]
        $NoNewFolder

    )

    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Enable DPI awareness
$code = @"
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
"@
    $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
    $null = $Win32Helpers::SetProcessDPIAware()

    $FolderBrowser              = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.RootFolder   = "MyComputer"

    $FinalPath = $null
    if($SpecialPath){
        $FinalPath = [Environment]::GetFolderPath($SpecialPath)
    }else{
        $FinalPath = $Path
    }

    $FinalPath = $FinalPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $FolderBrowser.SelectedPath = $FinalPath
    $FolderBrowser.Description  = $Title
    if($NoNewFolder) {$FolderBrowser.ShowNewFolderButton = $false}

    $Result = $FolderBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true}))

    if ($Result -eq 'OK') {
        return $FolderBrowser.SelectedPath
    }
}