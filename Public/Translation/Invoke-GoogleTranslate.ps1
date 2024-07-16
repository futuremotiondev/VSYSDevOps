

class SourceLanguage : System.Management.Automation.IValidateSetValuesGenerator
{
    [String[]] GetValidValues()
    {
        return $script:PairOfSourceLanguageAndCode
    }
}

class TargetLanguage : System.Management.Automation.IValidateSetValuesGenerator
{
    [String[]] GetValidValues()
    {
        return $script:PairOfTargetLanguageAndCode
    }
}

# https://wiki.freepascal.org/Using_Google_Translate
$ReturnTypeToQueryParameter =
@{
    Translation = 't'
    Alternative = 'at'
    Dictionary  = 'bd'
    Definition  = 'md'
    Synonym     = 'ss'
}

$ListOfSingleWordReturnType = @('Definition', 'Synonym', 'Example')
$ListOfReturnTypeThatTheTargetLanguageIsRequired = @('Translation', 'Alternative', 'Dictionary', 'Example')

<#
    .DESCRIPTION
    A function that uses the free Google Translate API.

    .PARAMETER InputObject
    Text to translate or word that can be treated differently depending on the value of the ReturnType parameter.

    .PARAMETER SourceLanguage
    Source language as code or English word.

    .PARAMETER TargetLanguage
    Target language as code or English word.

    .PARAMETER ReturnType
    The type of data to return, it can be any of these:

    [Translation, Alternative, DetectedLanguage, Dictionary, Definition, Synonym, Example]

    .PARAMETER AvailableLanguages
    Return an array with all the available languages with the English name and language code.

    .OUTPUTS
    PSCustomObject
    PSCustomObject[]

    .NOTES
    This function uses the free Google Translate API, if you try doing parallelism it will block.
#>
function Invoke-GoogleTranslate
{
    [OutputType([PSCustomObject], [PSCustomObject[]])]
    param
    (
        [Alias('Query')]
        [Parameter(Mandatory=$true, ParameterSetName='Translation', ValueFromPipeline = $true)]
        [string] $InputObject,

        [Alias('From')]
        [ValidateSet([SourceLanguage])]
        [Parameter(ParameterSetName='Translation')]
        [string] $SourceLanguage = 'auto',

        [Alias('To')]
        [ValidateSet([TargetLanguage])]
        [Parameter(ParameterSetName='Translation')]
        [string] $TargetLanguage,

        [ValidateSet('Translation', 'Alternative', 'DetectedLanguage', 'Dictionary', 'Definition', 'Synonym', 'Example')]
        [Parameter(ParameterSetName='Translation')]
        [string] $ReturnType = 'Translation',

        [Parameter(ParameterSetName='AvailableLanguages')]
        [switch] $AvailableLanguages
    )

    if ($AvailableLanguages)
    {
        return $script:LanguagesCsv
    }

    if ($ReturnType -in $ListOfSingleWordReturnType -and ($InputObject.Trim().Contains(' ') -or $InputObject.Trim().Contains("`n")))
    {
        Write-Error "The return type '$ReturnType' only works for single words, your input is '$InputObject'."
    }
    if ($ReturnType -in $ListOfReturnTypeThatTheTargetLanguageIsRequired -and -not $TargetLanguage)
    {
        Write-Error "You must specify a the TargetLanguage if the ReturnType is '$ReturnType'."
    }

    $sourceLanguageCode, $targetLanguageCode = TryConvertLanguageToCode $SourceLanguage $TargetLanguage

    $returnTypeAsQueryParameter = $ReturnTypeToQueryParameter[$ReturnType]

    $query = if ($ReturnType -eq 'Example')
    {
        # 'Example' does not work if there are capital letters
        [uri]::EscapeDataString($InputObject.ToLower())
    }
    else { [uri]::EscapeDataString($InputObject) }

    $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&dj=1&q=$query&sl=$sourceLanguageCode&tl=$targetLanguageCode&dt=t&dt=$returnTypeAsQueryParameter"

    try
    {
        $response = Invoke-WebRequest -Uri $uri -Method Get

        Write-Verbose -Message $response.Content

        $data = $response.Content | ConvertFrom-Json

        $result = switch ($ReturnType)
        {
            DetectedLanguage
            {
                [PSCustomObject]@{
                    SourceLanguage              = $data.src
                    SourceLanguageAsEnglishWord = $script:CodeToLanguage[$data.src]
                }
            }
            Translation
            {
                [PSCustomObject]@{
                    SourceLanguage              = $data.src
                    SourceLanguageAsEnglishWord = $script:CodeToLanguage[$data.src]
                    TargetLanguage              = $targetLanguageCode
                    TargetLanguageAsEnglishWord = $script:CodeToLanguage[$targetLanguageCode]
                    Translation = $data.sentences | Select-Object -ExpandProperty trans | Join-String
                }
            }
            Alternative
            {
                [PSCustomObject]@{
                    SourceLanguage              = $data.src
                    SourceLanguageAsEnglishWord = $script:CodeToLanguage[$data.src]
                    TargetLanguage              = $targetLanguageCode
                    TargetLanguageAsEnglishWord = $script:CodeToLanguage[$targetLanguageCode]
                    AlternativesPerLine = $data.alternative_translations
                        | Where-Object { $null -ne $_.alternative }
                        | Group-Object { $_.src_phrase }
                        | ForEach-Object {
                            [PSCustomObject]@{
                                SourceLine = $_.Name
                                TranslationAlternatives = @($_.Group[0].alternative | ForEach-Object { $_.word_postproc })
                            }
                        }
                }
            }
            Dictionary
            {
                [PSCustomObject]@{
                    SourceLanguage              = $data.src
                    SourceLanguageAsEnglishWord = $script:CodeToLanguage[$data.src]
                    Dictionary = $data.dict | ForEach-Object {
                        [PSCustomObject]@{
                            WordClass = $_.pos
                            Terms = $_.terms
                            Entries = foreach ($wordData in $_.entry)
                            {
                                [PSCustomObject]@{
                                    Word = $wordData.word
                                    ReverseTranslations = $wordData.reverse_translation
                                    Score = $wordData.score
                                }
                            }
                        }
                    }
                }
            }
            Definition
            {
                [PSCustomObject]@{
                    SourceLanguage              = $data.src
                    SourceLanguageAsEnglishWord = $script:CodeToLanguage[$data.src]
                    Definitions = foreach ($definitionData in $data.definitions)
                    {
                        [PSCustomObject]@{
                            WordClass = $definitionData.pos
                            Glossary = @($definitionData.entry | Select-Object -ExpandProperty gloss)
                        }
                    }
                }
            }
            Synonym
            {
                [PSCustomObject]@{
                    SourceLanguage              = $data.src
                    SourceLanguageAsEnglishWord = $script:CodeToLanguage[$data.src]
                    Translation = $data.sentences.trans
                    SynonymGroupsPerWordClass = foreach ($set in $data.synsets)
                    {
                        [PSCustomObject]@{
                            WordClass = $set.pos
                            Groups = foreach ($synonymData in $set.entry)
                            {
                                [PSCustomObject]@{
                                    Register = $synonymData.label_info.register
                                    Synonyms = @($synonymData.synonym)
                                }
                            }
                        }
                    }
                }
            }
            Example
            {
                [PSCustomObject]@{
                    SourceLanguage = $data.src
                    Translation = $data.sentences.trans
                    Examples = @($data.examples[0] | Select-Object -ExpandProperty example | Select-Object -ExpandProperty text)
                }
            }
        }

        return $result
    }
    catch [System.Net.WebException]
    {
        Write-Host "A network error occurred: $($_.Exception.Message)"
        return $null
    }
    catch [System.Net.Sockets.SocketException]
    {
        Write-Error "Host not found or no internet connection: $($_.Exception.Message)"
        return $null
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException]
    {
        Write-Host "HTTP error occurred: $($_.Exception.Message)"
        return $null
    }
    catch
    {
        Write-Error "An unknown error occurred: $($_.Exception.Message)"
        return $null
    }
}

function TryConvertLanguageToCode([string] $SourceLanguage, [string] $TargetLanguage)
{
    $languageCodes = @($SourceLanguage, $TargetLanguage)

    if ($script:LanguageToCode.ContainsKey($SourceLanguage))
    {
        $languageCodes[0] = $script:LanguageToCode[$SourceLanguage]
    }
    if ($script:LanguageToCode.ContainsKey($TargetLanguage))
    {
        $languageCodes[1] = $script:LanguageToCode[$TargetLanguage]
    }

    return $languageCodes
}