function Out-FileHash {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [String[]] $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [ValidateSet('ALL','SHA1','SHA256','SHA384','SHA512','MD5', ErrorMessage = "Invalid algorithm supplied.")]
        [Array] $Algorithm = 'ALL',

        [Switch] $SaveToFile,
        [Switch] $CopyToClipboard,
        [Switch] $DisplayConfirmation,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [String] $DestinationDirectory = 'Desktop'
    )

    begin {
        if($CopyToClipboard){
            [System.Windows.Forms.Clipboard]::Clear()
        }
    }

    process {

        $FormatAndPadOutput = {
            param (
                [Parameter(Mandatory)]
                [String] $HashStrings
            )
            # Split the string into lines
            $lines = $HashStrings -split "`n"

            # Determine the maximum length of the algorithm part
            $maxAlgorithmLength = ($lines | ForEach-Object { ($_ -split ':')[0].Trim().Length } | Measure-Object -Maximum).Maximum

            # Pad each line so that the hashes line up
            $paddedLines = $lines | ForEach-Object {

                $parts = $_ -split ':'
                $algorithm = $parts[0].Trim()
                $hash = $parts[1].Trim()

                # Pad the algorithm part with spaces to line up the hashes
                $paddedAlgorithm = $algorithm.PadRight($maxAlgorithmLength)

                # Reconstruct the line with the padded algorithm part
                "$paddedAlgorithm : $hash"
            }

            # Join the padded lines back into a single string
            $paddedString = $paddedLines -join "`n"
            return $paddedString
        }

        $FileHashQueue = [System.Collections.Queue]::new()

        foreach ($File in $Files) {

            $HashQueue = [System.Collections.Queue]::new()
            if($Algorithm -eq 'ALL'){ $SelectedAlgorithms = 'SHA1','SHA256','SHA384','SHA512','MD5' }
            else { $SelectedAlgorithms = $Algorithm }

            $FileName = [System.IO.Path]::GetFileName($File)

            foreach ($Alg in $SelectedAlgorithms) {
                $CurHash = Get-FileHash -LiteralPath $File -Algorithm $Alg
                $HashObj = [PSCustomObject]@{
                    File      =  $FileName
                    Algorithm =  $Alg
                    Hash      =  $CurHash.Hash
                }
                $HashQueue.Enqueue($HashObj)
            }

            $FormattedOutput = ""
            foreach($HObj in $HashQueue){
                $FormattedOutput += "$($HObj.Algorithm)`: $($HObj.Hash)`n"
            }
            $FormattedOutput = $FormattedOutput.TrimEnd("`r", "`n")
            $FormattedOutput = & $FormatAndPadOutput -HashStrings $FormattedOutput
            $FormattedOutput = "$FileName`:`n" + $FormattedOutput + "`n"

            $FileHashQueue.Enqueue($FormattedOutput)

            if($SaveToFile -and ($DestinationDirectory -eq 'Desktop')){
                $DestinationDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
                $DestinationFile = Join-Path $DestinationDirectory -ChildPath "Generated Hashes.txt"
                $DestinationFile = Get-UniqueNameIfDuplicate -LiteralPath $DestinationFile
            }

            if($SaveToFile){
                if(-not(Test-Path -LiteralPath $DestinationDirectory -PathType Container)) {
                    New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null
                    $DestinationFile = Join-Path $DestinationDirectory -ChildPath "Generated Hashes.txt"
                }
            }
        }

        if($SaveToFile){
            $FileHashQueue | Out-File -LiteralPath $DestinationFile -Encoding utf8 -Force
            $wshell = New-Object -ComObject wscript.shell;
            $wshell.SendKeys("{F5}")
        }
        if($CopyToClipboard){
            $FileHashQueue | Set-Clipboard
        }

        if($DisplayConfirmation){
            Invoke-VBMessageBox -Message "Operation Complete" -Title "Success" -BoxType OKOnly -Icon Information
        }
    }
}
