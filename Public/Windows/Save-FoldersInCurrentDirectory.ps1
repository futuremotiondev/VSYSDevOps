<#
.SYNOPSIS
    Creates folders in the specified directory (-Directory). If the directory does not exist, it can be
    created using the -Force parameter.

.DESCRIPTION
    The Save-FoldersInCurrentDirectory function takes a directory path and a list of folder names to
    create within that directory. If the directory does not exist, the -Force switch can be used to create
    it automatically.  The function ensures unique folder names by appending numbers if duplicates are
    found.

.PARAMETER Directory
    The path of the directory where the folders will be created. If the directory is invalid or does not
    exist, an error is thrown unless the -Force switch is used.

.PARAMETER FolderNames
    An array of folder names to be created within the specified directory.

.PARAMETER Force
    A switch parameter that, when specified, forces the creation of the directory if it does not exist.

.EXAMPLE
    # Create folders in an existing directory
    $folders = @("ProjectA", "ProjectB", "ProjectC")
    Save-FoldersInCurrentDirectory -Directory "C:\ExistingDirectory" -FolderNames $folders

.EXAMPLE
    # Create folders in a non-existing directory with force
    $newFolders = @("2023Reports", "2023Invoices")
    Save-FoldersInCurrentDirectory -Directory "D:\NewYearDocuments" -FolderNames $newFolders -Force

.EXAMPLE
    # Attempt to create folders in a non-existing directory without force
    $backupFolders = @("Backup1", "Backup2")
    Save-FoldersInCurrentDirectory -Directory "E:\Backups" -FolderNames $backupFolders
    (An error occurs: "Passed Directory is not valid or does not exist.")

.NOTES
    Author: Futuremotion
    Website: https://github.com/futuremotiondev
    Date: 10-03-2024
#>
function Save-FoldersInCurrentDirectory {

    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [ValidateNotNullOrEmpty()]
        [String] $Directory,
        [String[]] $FolderNames,
        [Switch] $Force
    )

    # Check if the specified directory exists
    $DirectoryExists = Test-Path -LiteralPath $Directory -PathType Container -ErrorAction SilentlyContinue

    # Validate directory existence or handle error if not forcing creation
    if(!$Directory -or (-not$DirectoryExists)){
        if(!$Force){
            # Error message for invalid or non-existent directory
            $ErrorMessage = "Passed Directory is not valid or does not exist. ($Directory) If you want the directory to be created automatically, use the -Force parameter."
            Write-Error -Message $ErrorMessage -ErrorAction Continue

            # Display a message box with the error information
            $invokeVBMessageBoxSplat = @{
                Message = $ErrorMessage
                Title = "Invalid directory"
                Icon = 'Information'
                BoxType = 'OKOnly'
            }
            Invoke-VBMessageBox @invokeVBMessageBoxSplat
            return
        }
    }

    # Create the directory if it does not exist and force is specified
    if(!$DirectoryExists -and $Force){
        New-Item -Path $Directory -ItemType Directory -Force | Out-Null
    }

    # Iterate over each folder name and create the folder in the specified directory
    foreach ($Folder in $FolderNames) {
        $DestPath = Join-Path -Path $Directory -ChildPath $Folder
        # Ensure unique folder name if duplicates exist
        $DestPath = Get-UniqueNameIfDuplicate -LiteralPath $DestPath
        New-Item -Path $DestPath -ItemType Directory -Force | Out-Null
    }

    # Refresh Windows Explorer to reflect changes
    Request-WindowsExplorerRefresh

}