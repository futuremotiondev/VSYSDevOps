function Update-PythonPackagesInVENV {
    param (
        [Parameter(Mandatory)]
        [String] $Folder,
        [switch] $NavigateToFolder
    )

    Push-Location -LiteralPath $PWD -StackName UpdateVENVPkg

    if(-not(Confirm-PythonFolderIsVENV -Folder $Folder)){
        throw "Passed -Folder ($Folder) is not a Python VENV"
    }

    Use-PythonActivateVENVInFolder -Folder $Folder -NavigateToFolder | Out-Null
    Update-PythonPIPInVENV -Folder $Folder

    $PackagesList = & pip freeze | ForEach-Object {$_.split('==')[0]}

    foreach ($Package in $PackagesList) {
        & pip install --upgrade $Package
    }

    if($NavigateToFolder){
        Set-Location $Folder
    }
    else {
        Pop-Location -StackName UpdateVENVPkg
    }
}