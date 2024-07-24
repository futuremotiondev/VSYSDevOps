function Format-StringRemoveUnusualSymbols {
    param (
        [parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('s')]
        [String[]] $String
    )

    begin {
        $SChar = '!', '™', '®', '©', '?', '§', '°', '√', '%', '«', '»', '~',
                 '□', '…', '†', '‡', 'ˆ', '‰', '‹', 'Œ', "‘", "’", '“', '”',
                 '•', '–', '˜', '›', '¦', 'ª', '¬', '¯', "°", "±", '²', '³',
                 '´', 'µ', '¶', '·', '¸', '¹', 'º', '¼', "½", "¾", '¿', '÷',
                 '→', '`', '?'

        $reSChar = [string]::join('|', ($SChar | % {[regex]::escape($_)}))
    }

    process {
        $String | ForEach-Object {
            $NewString = $_ -replace $reSChar, ''
            $NewString = $NewString -replace '\s{2,}', ' '
            $NewString
        }
    }
}