function Rename-SanitizeFilenames {
    [CmdletBinding()]
    param(
        [parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if ($_ -notmatch '[\?\*]') {
                $true
            } else {
                throw 'Wildcard characters *, ? are not acceptable with -LiteralPath'
            }
        })]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [String[]] $LiteralPath
    )

    process {

        $LiteralPath | ForEach-Object {

            $CurrentFile = $_
            if(-not(Test-Path -LiteralPath $CurrentFile)){
                Write-Warning "Passed path does not exist. ($CurrentFile)"
                return
            }

            $CurrentFileObject = Get-Item -LiteralPath $CurrentFile

            $NewName = Format-StringRemoveUnusualSymbols -String $CurrentFileObject.Name
            $NewName = Format-StringReplaceDiacritics -String $NewName
            Rename-Item -LiteralPath $CurrentFileObject.FullName -NewName $NewName | Out-Null

        }
    }
}