function Save-FilesToFolderByWord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false)]
        [Int32]
        $NumWords = 1,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = [System.Collections.Generic.List[String]]::new()
    }

    process {
        foreach ($P in $Files) {
            if	 ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path)       { $List.Add($P.Path) }
            elseif ($P.FullName)   { $List.Add($P.FullName) }
            elseif ($P.PSPath)     { $List.Add($P.PSPath) }
            else { Write-Error "Invalid argument passed to files parameter." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $File = $_
            $FileName      = [System.IO.Path]::GetFileName($File)
            $FileDirectory = [System.IO.Directory]::GetParent($File)

            if($Using:NumWords -eq 1){
                $RegExWord = '^(\w+)\b'
                $RegExReplace = '$1\$0'
            }

            if($Using:NumWords -eq 2){
                $RegExWord = '^(\w+)[\s|\-](\w+)\b'
                $RegExReplace = '$1 $2\$0'
            }

            if($Using:NumWords -eq 3){
                $RegExWord = '^(\w+)[\s|\-](\w+)[\s|\-](\w+)\b'
                $RegExReplace = '$1 $2 $3\$0'
            }


            # Insert the first word occuring in the filename
            # as a prefixed subdirectory
            $Step1 = $FileName
            $Step2 = $Step1 -replace $RegExWord, $RegExReplace

            # Remove everything after the first '\' Leaving
            # Just the first word.
            $parts = $Step2 -split '\\'
            $Step3 = $parts[0]

            # Whitespace Cleanup
            $Step4 = $Step3 -replace '\s+', ' '
            $Step4 = $Step4.Trim()

            # Camel Case Conversion
            [System.String]$Step5 = $Step4 -csplit '(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', -join ' '
            $DestDirectory = Join-Path -Path $FileDirectory -ChildPath $Step5
            if(!(Test-Path -LiteralPath $DestDirectory -PathType Container)){
                [IO.Directory]::CreateDirectory($DestDirectory) | Out-Null
            }

            $NewFullFilePath = [IO.Path]::Combine($DestDirectory, $FileName)
            [IO.File]::Move($File, $NewFullFilePath)

        } -ThrottleLimit $MaxThreads
    }
}