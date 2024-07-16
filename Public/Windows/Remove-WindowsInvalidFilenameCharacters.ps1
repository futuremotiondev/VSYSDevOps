function Remove-WindowsInvalidFilenameCharacters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String] $Name
    )

    process {
        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
        $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
        return ($Name -replace $re)
    }
}