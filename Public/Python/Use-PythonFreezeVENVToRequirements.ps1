function Use-PythonFreezeVENVToRequirements {
    param (
        [Parameter(Mandatory,Position=0)]
        [String] $Folder,
        [Switch] $NavigateToFolder
    )

    if(-not(Confirm-PythonFolderIsVENV -Folder $Folder)){
        throw "Passed -Folder ($Folder) is not a Python VENV"
    }

    Use-PythonActivateVENVInFolder -Folder $Folder | Out-Null

    & pip freeze > requirements.txt

    if($NavigateToFolder){
        Set-Location $Folder
    }

}