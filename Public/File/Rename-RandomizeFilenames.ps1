function Rename-RandomizeFilenames {
    [cmdletbinding()]
    param(
        [parameter( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [String[]] $Files,
        [Int32] $MaxThreads = 14
    )

    begin {
        $FileList = [System.Collections.Generic.List[string]]@()
    }


    process {
        foreach ($File in $Files) {
            if (Test-Path -Path $File -PathType Leaf) {
                $FileList.Add($File)
            }
        }
    }

    end {

        $FileList | ForEach-Object -Parallel {

            $CurrentFile = $_
            $RandomStr   = Get-RandomAlphanumericString -Length 20
            $NewFilename = $RandomStr + [System.IO.Path]::GetExtension($CurrentFile)
            Rename-Item -LiteralPath $CurrentFile -NewName $NewFilename -Force

        } -ThrottleLimit $MaxThreads
    }
}