function Rename-SanitizeFilenamesInFolder {
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
        [String[]] $LiteralPath,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('All','Folders','Files', IgnoreCase = $true)]
        [String] $WhatToProcess = 'All',

        [Switch] $Recurse
    )

    process {
        $LiteralPath | ForEach-Object {
            $RootFolder = $_
            if(-not(Test-Path -LiteralPath $RootFolder -PathType Container)){
                Write-Warning "Passed path is not a folder, or does not exist. ($RootFolder)"
                return
            }

            if ($WhatToProcess -eq 'All' -or $WhatToProcess -eq 'Folders') {
                $FoldersToRename = Get-ChildItem -LiteralPath $RootFolder -Directory -Recurse:$Recurse
                $FoldersToRename | Sort-Object -Property FullName -Descending | ForEach-Object {
                    $NewName = Format-StringRemoveUnusualSymbols -String $_.Name
                    $NewName = Format-StringReplaceDiacritics -String $NewName
                    Rename-Item -LiteralPath $_.FullName -NewName $NewName | Out-Null
                }
            }

            if ($WhatToProcess -eq 'All' -or $WhatToProcess -eq 'Files') {
                $FilesToRename = Get-ChildItem -LiteralPath $RootFolder -File -Recurse:$Recurse
                $FilesToRename | ForEach-Object {
                    $NewName = Format-StringRemoveUnusualSymbols -String $_.Name
                    $NewName = Format-StringReplaceDiacritics -String $NewName
                    Rename-Item -LiteralPath $_.FullName -NewName $NewName | Out-Null
                }
            }
        }
    }
}