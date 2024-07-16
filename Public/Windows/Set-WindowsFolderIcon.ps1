# REFACTOR: Code quality.
function Set-WindowsFolderIcon {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "All", Position = 0)]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Icon", Position = 0)]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Reset", Position = 0)]
        [ValidateScript({
            if (!(Test-Path -LiteralPath $_)) {
                throw [System.ArgumentException] "File or Folder does not exist."
            }
            if (Test-Path -LiteralPath $_ -PathType Leaf) {
                throw [System.ArgumentException] "File passed when a folder was expected."
            }
            return $true
        })]
        [String[]]
        $Folder,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Icon")]
        [ValidateScript({
            if (!(Test-Path -LiteralPath $_)) {
                throw [System.ArgumentException] "File or Folder does not exist."
            }
            if (Test-Path -LiteralPath $_ -PathType Container) {
                throw [System.ArgumentException] "Folder passed when a file was expected."
            }
            if ($_ -notmatch "(\.ico)") {
                throw [System.ArgumentException] "The file specified must be of type .ico"
            }
            return $true
        })]
        [String]
        $Icon,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "Reset")]
        [Switch]
        $Reset
    )

    process {
        foreach ($FolderToChange in $Folder) {
            if(!($Reset)){

                # Create a temp directory to store our
                # desktop.ini file before moving it
                $TmpDir = (Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName()))
                mkdir $TmpDir -force >$null
                $TmpIniPath = "$TmpDir\desktop.ini"

                # Define desktop.ini content
                $INIContent = @(
                "[.ShellClassInfo]"
                "IconFile=$Icon"
                "IconIndex=0"
                "ConfirmFileOp=0"
                ""
                ) -join "`r`n"

                # Pipe desktop.ini content out into an actual file.
                $INIContent | Out-File $TmpIniPath -Force
                (Get-Item -LiteralPath $TmpIniPath).Attributes = 'Archive, System, Hidden'

                # Remove existing desktop.ini file if
                # it exists in our target folder
                $IniFilePath = "$FolderToChange\desktop.ini"
                if(Test-Path -LiteralPath $IniFilePath -PathType Leaf){
                    Remove-Item -LiteralPath $IniFilePath -Force
                }

                # Desktop.ini must be updated using a Shell API method
                # in order for the Shell/Explorer to be notified
                # This is the secret sauce for getting icons to display
                # and refresh immediately.
                #
                # FOF_SILENT            0x0004 don't display progress UI
                # FOF_NOCONFIRMATION    0x0010 don't display confirmation UI, assume "yes"
                # FOF_NOERRORUI         0x0400 don't put up error UI
                #
                $shell = New-Object -com Shell.Application
                $shell.NameSpace($FolderToChange).MoveHere($TmpIniPath, 0x0004 + 0x0010 + 0x0400)

                Request-WindowsExplorerRefresh

                # Clean up and remove our temp directory
                Remove-Item -LiteralPath $TmpDir -Recurse -Force

                # Set the ReadOnly attribute on our folder so
                # Explorer knows to use the desktop.ini file.
                $FolderObject = Get-Item -LiteralPath $FolderToChange
                $FolderObject.Attributes = 'ReadOnly,Directory'

            }else{

                # Reset code:
                # Remove desktop.ini and revert folder attributes
                if(Test-Path -LiteralPath "$FolderToChange\desktop.ini" -PathType Leaf){
                    Remove-Item -LiteralPath "$FolderToChange\desktop.ini" -Force
                }
                (Get-Item -LiteralPath $FolderToChange).Attributes = 'Directory'

                Request-WindowsExplorerRefresh

            }
        }
    }

    end {
        # Refresh the icon cache just for good measure
        $cmd = 'ie4uinit.exe -show'
        Invoke-Expression $cmd
    }
}