<#
.SYNOPSIS
    Validates paths for the presence of wildcards and invalid characters.

.DESCRIPTION
    The `Test-ValidWildcardPath` function checks if each path in the provided array is valid by ensuring it does not contain wildcards or invalid characters.
    It can output a boolean value indicating validity or a custom object with detailed information.

.PARAMETER Path
    An array of paths to validate. Each path is checked against a regular expression that excludes invalid path characters and ensures no wildcards are present.

.PARAMETER OutputObject
    A switch parameter. If specified, the function returns a custom object containing the path and its validity status. Otherwise, it returns a simple boolean value.

.EXAMPLE
    # Example 1: Validate a single path without outputting an object
    $result = Test-ValidWildcardPath -Path "C:\Program Files\ExampleApp\file.txt"
    Write-Output $result

.EXAMPLE
    # Example 2: Validate multiple paths and return detailed objects
    $paths = @(
        "D:\Data\Projects\Report.docx",
        "E:\Music\Playlist?.mp3",
        "F:\Photos\Summer2023\Beach.jpg"
    )
    $results = Test-ValidWildcardPath -Path $paths -OutputObject
    $results | Format-Table -AutoSize

.EXAMPLE
    # Example 3: Validate paths using the pipeline
    "G:\Games\NewGame.exe", "H:\Downloads\*.*" | Test-ValidWildcardPath -OutputObject | Format-List

.NOTES
    Author: Futuremotion
    Date: 10-12-2024
    Website: https://github.com/futuremotiondev
#>
function Test-ValidWildcardPath {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path,
        [Switch] $OutputObject
    )

    begin {
        $re = '^[a-z]:[/\\][^{0}]*$' -f [regex]::Escape(([IO.Path]::InvalidPathChars -join ''))
    }

    process {
        $Results = @()
        foreach ($Item in $Path) {

            $isValid = $true
            if ($OutputObject) {
                $Obj = [PSCustomObject]@{ Path = $Item; Valid = $null; }
            }
            if ($Item -notmatch $re) {
                Write-Verbose "Path is not valid"
                $isValid = $false
            }
            if ($OutputObject) {
                $Obj.Valid = $isValid
                $Results += $Obj
            } else {
                $Results += $isValid
            }
        }

        $Results
    }
}