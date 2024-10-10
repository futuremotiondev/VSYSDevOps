function Save-FilesToFolderByWord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] $Files,
        [Parameter(Mandatory=$false)]
        [Int32] $NumWords = 1,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32] $MaxThreads = 16
    )

    begin {
        $List = [System.Collections.Generic.List[String]]::new()
    }

    process {
        foreach ($File in $Files) {
            $List.Add($File) | Out-Null
        }
    }

    end {

        $DelimStr = '[\s\.]'

        $List | ForEach-Object -Parallel {

            $File = $_
            $FileName = [System.IO.Path]::GetFileName($File)
            $FileDirectory = [System.IO.Directory]::GetParent($File)
            $DelimStr = $Using:DelimStr

            if($Using:NumWords -eq 1){
                $RegExWord = "^(\w+)$DelimStr"
                $RegExReplace = '$1\$0'
            }

            if($Using:NumWords -eq 2){
                $RegExWord = "^(\w+)$DelimStr(\w+)$DelimStr"
                $RegExReplace = '$1 $2\$0'
            }

            if($Using:NumWords -eq 3){
                $RegExWord = "^(\w+)$DelimStr(\w+)$DelimStr(\w+)$DelimStr"
                $RegExReplace = '$1 $2 $3\$0'
            }

            # Insert the first word occuring in the filename
            # as a prefixed subdirectory
            $Step1 = $FileName
            $Step2 = $Step1 -replace $RegExWord, $RegExReplace

            # # Remove everything after the first '\' Leaving
            # # Just the first word.
            $parts = $Step2 -split '\\'
            $Step3 = $parts[0]

            # Whitespace Cleanup
            $Step4 = $Step3 -replace '\s+', ' '
            $Step4 = $Step4.Trim()

            # Camel Case Conversion
            # [System.String]$Step5 = $Step4 -csplit '(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', -join ' '
            # Write-Host -f Green "`$Step5:" $Step5

            $DestDirectory = Join-Path -Path $FileDirectory -ChildPath $Step4
            if(!(Test-Path -LiteralPath $DestDirectory -PathType Container)){
                [IO.Directory]::CreateDirectory($DestDirectory) | Out-Null
            }

            $NewFullFilePath = [IO.Path]::Combine($DestDirectory, $FileName)
            Move-Item -LiteralPath $File -Destination $NewFullFilePath -Force | Out-Null

        } -ThrottleLimit $MaxThreads
    }
}
