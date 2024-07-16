function Invoke-SaveFileDialog {

    param(

        [Parameter(Mandatory,ParameterSetName='Path')]
        [string] $Path,

        [Parameter(Mandatory,ParameterSetName='SpecialFolder')]
        [System.Environment+SpecialFolder] $SpecialPath,

        [Parameter(Mandatory=$false)]
        [string] $DefaultFileName,

        [Parameter(Mandatory=$false)]
        [string] $Title,

        # Gets or sets the current file name filter string, which determines the
        # choices that appear in the "Save as file type" or "Files of type" box in
        # the dialog box.
        # For each filtering option, the filter string contains a description of the
        # filter, followed by the vertical bar (|) and the filter pattern. The
        # strings for different filtering options are separated by the vertical bar.
        # Example filter strings:
        #
        # Text File (*.txt)|*.txt
        # Markdown File (*.md)|*.md
        # Powershell Files(*.ps1;*.psd1;*.psm1;)|*.ps1;*.psd1;*.psm1;
        # C# Files(*.cs;*.csproj;*.sln;)
        # Raster Image Files(*.JPG;*.JPEG;*.JP2;*.J2K;*.PNG;*.TIFF;*.TIF;*.EXR;*.BMP;*.WebP;)|*.JPG;*.JPEG;*.JP2;*.J2K;*.PNG;*.TIFF;*.TIF;*.EXR;*.BMP;*.WebP;
        # Vector Image Files(*.SVG;*.EPS;*.AI;*.PDF;*.CDR;*.WMF;*.EMF;*.DXF;)|*.SVG;*.EPS;*.AI;*.PDF;*.CDR;*.WMF;*.EMF;*.DXF;
        # RAW Image Files Full(*.CR2;*.RAF;*.RW2;*.ERF;*.NRW;*.NEF;*.ARW;*.RWZ;*.EIP;*.DNG;*.BAY;*.DCR;*.GPR;*.RAW;*.CRW;*.3FR;*.SR2;*.K25;*.KC2;*.MEF;*.DNG;*.CS1;*.ORF;*.MOS;*.KDC;*.CR3;*.ARI;*.SRF;*.SRW;*.J6I;*.FFF;*.MRW;*.MFW;*.RWL;*.X3F;*.PEF;*.IIQ;*.CXI;*.NKSC;*.MDC;)|*.CR2;*.RAF;*.RW2;*.ERF;*.NRW;*.NEF;*.ARW;*.RWZ;*.EIP;*.DNG;*.BAY;*.DCR;*.GPR;*.RAW;*.CRW;*.3FR;*.SR2;*.K25;*.KC2;*.MEF;*.DNG;*.CS1;*.ORF;*.MOS;*.KDC;*.CR3;*.ARI;*.SRF;*.SRW;*.J6I;*.FFF;*.MRW;*.MFW;*.RWL;*.X3F;*.PEF;*.IIQ;*.CXI;*.NKSC;*.MDC;
        # RAW Image Files Common(*.CR2;*.NEF;*.DNG;*.DCR;*.RAW;*.MEF;*.DNG;*.CR3;*.MRW;*.MFW;*.X3F;)|*.CR2;*.NEF;*.DNG;*.DCR;*.RAW;*.MEF;*.DNG;*.CR3;*.MRW;*.MFW;*.X3F;
        [Parameter(Mandatory=$false)]
        [string] $FilterString,

        # The default file name extension. The returned string does not include the
        # period. The default value is an empty string ("").
        #
        # DefaultExt is only used when "All files" is selected from the filter box
        # and no extension is specified by the user.
        #
        # When the user of your application specifies a file name without an
        # extension, the FileDialog appends an extension to the file name. The
        # extension that is used is determined by the Filter and DefaultExt
        # properties.
        #
        # If a filter is selected in the FileDialog and the filter specifies an
        # extension, then that extension is used. If the filter selected uses a
        # wildcard in place of the extension, then the extension specified in the
        # DefaultExt property is used.

        [Parameter(Mandatory=$false)]
        [string] $DefaultExt

    )

    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Enable DPI awareness
$code = @"
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
"@
    $Win32Helpers = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru
    $null = $Win32Helpers::SetProcessDPIAware()

    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog

    if($FilterString){ $SaveFileDialog.Filter = $FilterString }
    else{ $SaveFileDialog.Filter = "All files (*.*)|*.*" }

    if($DefaultFileName){ $SaveFileDialog.FileName = $DefaultFileName }
    else { $SaveFileDialog.FileName = '' }

    if($Title){ $SaveFileDialog.Title = $Title }
    else { $SaveFileDialog.Title = "Save File..."}

    if($DefaultExt){ $SaveFileDialog.DefaultExt = $DefaultExt }

    $SaveFileDialog.OverwritePrompt = $true
    $SaveFileDialog.AddExtension = $true

    switch ($PSCmdlet.ParameterSetName) {
        'Path'  {
            $InitialDirectory = $Path
            break
        }
        'SpecialFolder' {
            $InitialDirectory = [Environment]::GetFolderPath($SpecialPath)
            break
        }
    }

    $InitialDirectory = $InitialDirectory.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $InitialDirectory = $InitialDirectory + [System.IO.Path]::DirectorySeparatorChar
    $SaveFileDialog.InitialDirectory = $InitialDirectory

    [System.Windows.Forms.Form] $SaveFileForm = New-Object System.Windows.Forms.Form
    $SaveFileForm.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
    $SaveFileForm.TopMost = $true
    $Result = $SaveFileDialog.ShowDialog($SaveFileForm)

    [PSCustomObject]@{
        Result = $Result
        Filepath = $SaveFileDialog.FileName
    }
}