function Use-PythonActivateVENVInFolder {
    param (
        [Parameter(Mandatory)]
        [String] $Folder,
        [Switch] $NavigateToFolder
    )

    if(-not(Confirm-PythonFolderIsVENV -Folder $Folder)){
        throw "Passed -Folder ($Folder) is not a Python VENV"
    }

    $ActivateScript = [System.IO.Path]::Combine($Folder, 'Scripts', 'Activate.ps1')
    if(Test-Path $ActivateScript -PathType Leaf){
        & $ActivateScript
        if($NavigateToFolder){
            Set-Location $Folder
        }
    }
    else{
        Write-Error "Activation script is missing from the passed VENV folder ($Folder)"
        return
    }
}