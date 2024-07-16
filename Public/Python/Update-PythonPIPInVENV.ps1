function Update-PythonPIPInVENV {
    param (
        [Parameter(Mandatory)]
        [String] $Folder,
        [switch] $NavigateToFolder
    )

    Clear-Host

    if(-not(Confirm-PythonFolderIsVENV -Folder $Folder)){
        throw "Passed -Folder ($Folder) is not a Python VENV"
    }

    Use-PythonActivateVENVInFolder -Folder $Folder -NavigateToFolder | Out-Null

    [String] $PYPipString = & pip --version

    $rePIPDetails =  '^pip ([\d\.]+) from (.*) \(python ([\d\.]+)\)'
    if ($PYPipString -match $rePIPDetails) {
        $pyPIPVersion    =  $matches[1]
        $pyPIPPath       =  $matches[2]
        $pyPythonVersion =  $matches[3]
    }

    Write-SpectreHost "[#FFFFFF]Updating PIP [#aeebd3](v$pyPIPVersion)[/] for Python (v$pyPythonVersion)[/]"
    Write-SpectreHost "[#FFFFFF]PIP Location: [#aeebd3]$pyPIPPath[/][/]"
    Write-Host ""

    & pip install --upgrade pip

    Write-Host ""

    if($NavigateToFolder){
        Set-Location $Folder
    }
}