function ConvertTo-TitleCase {

    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $String,
        [String] $Delimiter = " "
    )
    begin {
        $Words = $String.Split($Delimiter)
        $FormattedWords = [System.Collections.ArrayList]@()
    }
    Process {
        foreach ($Word in $Words) {
            [Void] $FormattedWords.Add((Get-Culture).TextInfo.ToTitleCase($Word.ToLower()))
        }
        $FormattedString = $FormattedWords -join " "
        return $FormattedString
    }
}

<#
.SYNOPSIS
    Format a string

.DESCRIPTION
    Convert a string to a specified format

.PARAMETER String
    The string parameter corresponds to the string to format. It can be a single
    word or a complete sentence.

.PARAMETER Format
    The format parameter corresponds to the case to convert the string to.
    The following values are available:
    - CamelCase
    - KebabCase
    - LowerCase
    - PaslcalCase
    - SentenceCase
    - SnakeCase
    - TitleCase
    - TrainCase
    - UpperCase

.PARAMETER Delimiter
    The delimiter parameter corresponds to the character used to delimit dis-
    tinct words in the string.
    The default delimiter for words is the space character

.NOTES
    When the output word delimiter is not a space (i.e. the formatted string is
    not a sentence), all punctuation is stripped from the string.
#>
function Format-String {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String] $String,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet ("CamelCase", "KebabCase", "LowerCase", "PaslcalCase", "SentenceCase", "SnakeCase", "TitleCase", "TrainCase", "UpperCase", IgnoreCase=$true)]
        [String] $Format,

        [Parameter ( Mandatory = $false )]
        [String] $Delimiter = " "

    )

    begin {
        # List cases that have to be capitalized
        $Delimiters = [Ordered]@{
            "CamelCase" = ""
            "KebabCase" = "-"
            "LowerCase" = $Delimiter
            "PaslcalCase" = ""
            "SentenceCase" = " "
            "SnakeCase" = "_"
            "TitleCase" = " "
            "TrainCase" = "_"
            "UpperCase" = $Delimiter
        }
        $Capitalise = [Ordered]@{
            First = @("PaslcalCase", "SentenceCase", "TitleCase", "TrainCase")
            Others = @("CamelCase", "PaslcalCase", "SentenceCase", "TitleCase", "TrainCase")
        }
        # Create array of words
        if ($Delimiters.$Format -ne " ") {
            $String = $String -replace ("[^A-Za-z0-9\s]", "")
        }
        $Words = $String.Split($Delimiter)
        $Counter = 0
        $FormattedWords = [System.Collections.ArrayList]@()
    }

    process {
        foreach ($Word in $Words) {
            if ($Format -ne "UpperCase") {
                if ($Counter -gt 0) {
                    if ($Format -in $Capitalise.Others) {
                        [Void]$FormattedWords.Add((ConvertTo-TitleCase -String $Word))
                    } else {
                        [Void]$FormattedWords.Add($Word.ToLower())
                    }
                } else {
                    if ($Format -in $Capitalise.First) {
                        [Void]$FormattedWords.Add((ConvertTo-TitleCase -String $Word))
                    } else {
                        [Void]$FormattedWords.Add($Word.ToLower())
                    }
                }
            } else {
                [Void]$FormattedWords.Add($Word.ToUpper())
            }
            $Counter += 1
        }
        # Reconstruct string
        $FormattedString = $FormattedWords -join $Delimiters.$Format
        return $FormattedString
    }
}
