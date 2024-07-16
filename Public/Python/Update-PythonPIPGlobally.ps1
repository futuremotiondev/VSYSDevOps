function Update-PythonPIPGlobally {

    Clear-Host
    Write-Host ""

    try {
        $PYCmd = Get-Command py.exe -CommandType Application
    } catch {
        throw "Can't find py.exe in PATH (Python Launcher)."
    }

    $PyVersions = Get-PythonInstalledVersions -VersionOnly -ReverseResults
    if([String]::IsNullOrEmpty($PyVersions)){
        throw "No installed versions of Python were found."
    }

    foreach ($Version in $PyVersions) {

        #$Matches = $null
        $PYParams1 = "-$Version", '-m', 'pip', '--version'
        [String] $PYPipString = & $PYCmd $PYParams1

        $rePIPDetails    =  '^pip ([\d\.]+) from (.*) \(python ([\d\.]+)\)'
        $pyPIPVersion    =  ''
        $pyPIPPath       =  ''
        $pyPythonVersion =  ''

        ($PYPipString -match $rePIPDetails)

        if ($PYPipString -match $rePIPDetails) {
            $pyPIPVersion    =  $matches[1]
            $pyPIPPath       =  $matches[2]
            $pyPythonVersion =  $matches[3]
        }

        Write-SpectreHost "[#FFFFFF]Updating PIP [#aeebd3](v$pyPIPVersion)[/] for Python (v$pyPythonVersion)[/]"
        Write-SpectreHost "[#FFFFFF]PIP Location: [#aeebd3]$pyPIPPath[/][/]"
        Write-Host ""

        $PYParams2 = "-$Version", '-m', 'pip', 'install', '--upgrade', 'pip'
        & $PYCmd $PYParams2

        Write-Host ""
    }
}