function Get-PythonInstallations {

    [CmdletBinding()]
    param (
        [Switch] $SuppressFreeThreaded
    )

    if($Ascending -and $Descending){
        throw "The Ascending and Descending switches cannot be used together."
    }

    $PYLauncherCMD = Get-Command py.exe -CommandType Application
    if(!$PYLauncherCMD) { throw "Py Launcher (py.exe) is not available in PATH." }
    $PY1 = (& $PYLauncherCMD -0) -split "\r?\n"
    $PY2 = (& $PYLauncherCMD -0p) -split "\r?\n"

    for ($idx = 0; $idx -lt $PY1.Count; $idx++) {

        [String] $PY1VersString = $PY1[$idx]
        [String] $PY2VersString = $PY2[$idx]

        $VString = [regex]::Escape('-V:')
        $ShortVersion = ((($PY1VersString -replace $VString, '').Trim()) -replace '[\s\*]+Python\s([\d\.]+)(.*)$', '')
        $Bitness = $PY1VersString -replace '^(:?.*)(\(.*\))$', '$2' -replace ',[\s]freethreaded\)', ') FT' -replace '^\(', '' -replace '\)$',''
        $Path = ($PY2VersString -replace '^(:?\s\-V\:)', '') -replace '[\s\*]+', ' ' -replace '(.*) (.*)$', '$2'
        $PyBinary = [System.IO.Path]::GetFileName($Path)

        $IsFreeThreaded = $false
        $Params = '--version'
        [String] $VersionString = & $Path $Params
        $VersionString = $VersionString.Trim()
        $FullVersion = $VersionString.TrimStart('Python ').Trim()

        if($ShortVersion -match '(\d\.*)t'){
            if($SuppressFreeThreaded){ continue }
            $ShortVersion = $ShortVersion.TrimEnd('t')
            #$FullVersion = $FullVersion + " FT"
            $Bitness = $Bitness.TrimEnd(' FT') -replace '\)$',''
            $IsFreeThreaded = $true
        }

        $Bitness = $Bitness -replace '\-bit', ''

        [PSCustomObject]@{
            Python = $VersionString
            Version = $ShortVersion
            FullVersion = $FullVersion
            Arch = $Bitness
            PythonPath = $Path
            FreeThreaded = $IsFreeThreaded
            PythonBinary = $PyBinary
        }
    }
}