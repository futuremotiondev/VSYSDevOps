<#
.SYNOPSIS
    Saves Base64-encoded input to a file, optionally determining file type and handling file dialogs.

.DESCRIPTION
    This function decodes a Base64-encoded string and saves it to a specified file location. Depending on the parameter set used, it either prompts the user with a save file dialog or uses a specified file path.

.PARAMETER Base64Input
    Specifies the Base64-encoded input string to be decoded and saved as a file.

.PARAMETER DestinationFile
    Specifies the destination file path where the decoded content will be saved. Used when `-FileSpecified` parameter set is chosen.

.PARAMETER OverwriteExistingFile
    If specified and `$true`, allows overwriting an existing file at the destination file path.

.PARAMETER UseDialog
    Switch parameter that, when specified, prompts the user with a save file dialog to choose the destination file path.

.EXAMPLE
    Save Base64-encoded string to a specified file path:
    Save-Base64StringToFile -Base64Input "VGhpcyBpcyBhIGZpbGUgc3RyaW5nIGlzIGJpbmFyeSB0byBzYXZlIGEgZmlsZSBwb3NpdGl2ZSB0byB0aGUgc3RhcnRzIHRvIG1ha2UgdGhlIHNhbWUgZmlsZSBkYXRhLg==" -DestinationFile "C:\path\to\output.txt"

.EXAMPLE
    Save Base64-encoded string using a save file dialog:
    Save-Base64StringToFile -Base64Input "VGhpcyBpcyBhIGZpbGUgc3RyaW5nIGlzIGJpbmFyeSB0byBzYXZlIGEgZmlsZSBwb3NpdGl2ZSB0byB0aGUgc3RhcnRzIHRvIG1ha2UgdGhlIHNhbWUgZmlsZSBkYXRhLg==" -UseDialog

.NOTES
    Author: Futuremotion
    Website: https://github.com/futuremotiondev
#>

function Save-Base64StringToFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String] $Base64Input,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="FileSpecified")]
        [String] $DestinationFile,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName,ParameterSetName="FileSpecified")]
        [String] $OverwriteExistingFile,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="UseDialog")]
        [Switch] $UseDialog
    )

    begin {}

    process {

        try {
            $Base64Input = $Base64Input.Trim()
            $ContentBytes = [Convert]::FromBase64String($Base64Input)
        } catch {
            throw "Couldn't decode -Base64Input string."
        }

        if($PSCmdlet.ParameterSetName -eq 'UseDialog'){

            $FormFilterStringArray = [System.Collections.Generic.List[String]]@()
            $FormFilterStringArray.Add("All files (*.*)|*.*")
            $FormFilterStringArray.Add("SVG (*.SVG;)|*.SVG")
            $FormFilterStringArray.Add("ICO (*.ICO;)|*.ICO")
            $FormFilterStringArray.Add("JPG (*.JPG;)|*.JPG")
            $FormFilterStringArray.Add("JPEG (*.JPEG;)|*.JPEG")
            $FormFilterStringArray.Add("PNG (*.PNG;)|*.PNG")
            $FormFilterStringArray.Add("TIFF (*.TIFF;)|*.TIFF")
            $FormFilterStringArray.Add("TIF (*.TIF;)|*.TIF")
            $FormFilterStringArray.Add("BMP (*.BMP;)|*.BMP")
            $FormFilterStringArray.Add("EPS (*.EPS;)|*.EPS")
            $FormFilterStringArray.Add("PDF (*.PDF;)|*.PDF")
            $FormFilterString = $FormFilterStringArray -join "|"

            $FileSaveResult = Invoke-SaveFileDialog -SpecialPath Desktop -Title "Save Decoded File..." -FilterString $FormFilterString
            if($FileSaveResult.Result -eq 'OK'){
                $FileSaveDestination = $FileSaveResult.Filepath
            }
            else{
                Write-Error "User cancelled the file save operation."
                return
            }
        }
        else{
            if($OverwriteExistingFile){
                $FileSaveDestination = $DestinationFile
            }
            else{
                $FileSaveDestination = Get-UniqueFileOrFolderNameIfDuplicate -Path $DestinationFile
            }
        }

        try {
            [IO.File]::WriteAllBytes($FileSaveDestination, $ContentBytes)
            Request-WindowsExplorerRefresh
        } catch {
            throw "Failed to write content to file '$FileSaveDestination': $_"
        }

        [PSCustomObject]@{
            SavedFilePath = $FileSaveDestination
            FileSizeBytes = $ContentBytes.Length
        }
    }

    end {}

}