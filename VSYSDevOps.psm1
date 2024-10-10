if (-not $script:DevOpsModuleRoot) {
    $script:DevOpsModuleRoot = $PSScriptRoot
}

$Public = Get-ChildItem $PSScriptRoot\Public -Recurse -Include '*.ps1' -ea SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private -Recurse -Include '*.ps1' -ea SilentlyContinue

foreach ($Import in @($Public + $Private)) {
    try { . $Import.FullName } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}


## Google Translate Variables  ######################################################
#####################################################################################


if(-not($script:LanguagesCsv)){
    $script:LanguagesCSVFile = Join-Path -Path $script:DevOpsModuleRoot -ChildPath 'Languages.csv'
    $script:LanguagesCsv = ConvertFrom-Csv -InputObject (Get-Content $script:LanguagesCSVFile -Raw)
}
$script:LanguageToCode = @{}
$script:CodeToLanguage = @{}

foreach ($row in $script:LanguagesCsv)
{
    $script:LanguageToCode[$row.Language] = $row.Code
    $script:CodeToLanguage[$row.Code] = $row.Language
}

$script:PairOfSourceLanguageAndCode = $script:LanguagesCsv | ForEach-Object { $_.Language, $_.Code }
$script:PairOfTargetLanguageAndCode = $script:LanguagesCsv | Where-Object { $_.Code -ine 'auto' } | ForEach-Object { $_.Language, $_.Code }

if (-not $script:PythonInstalledVersionsCompleter) {
    $script:PythonInstalledVersionsCompleter = Get-PythonInstallations -SuppressFreeThreaded
}

