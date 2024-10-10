Function Test-DirectoryForPwshFiles {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position=0)]
        [string] $Directory,

        [ValidateSet('All', 'ps1', 'psm1', 'psd1')]
        [string] $Filter = 'All'
    )

    $Extensions = @()
    Switch ($Filter) {
        'All'  { $Extensions = @('*.ps1', '*.psm1', '*.psd1') }
        'ps1'  { $Extensions = @('*.ps1') }
        'psm1' { $Extensions = @('*.psm1') }
        'psd1' { $Extensions = @('*.psd1') }
    }

    If (-Not (Test-Path -Path $Directory -PathType Container)) {
        Write-Warning "The directory '$Directory' does not exist."
        return $false
    }

    $PowerShellFiles = Get-ChildItem -Path $Directory -Include $Extensions -File -Recurse

    If ($PowerShellFiles.Count -gt 0) {
        return $true
    }
    else {
        return $false
    }
}

