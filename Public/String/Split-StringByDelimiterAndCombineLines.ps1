function Split-StringByDelimiterAndCombineLines {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $InputString,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Delimiter,
        [Int32] $SkipEvery = 1
    )

    process {
        $splitArray = $InputString -split $Delimiter
        $resultArray = @()

        for ($i = 0; $i -lt $splitArray.Length; $i += $SkipEvery + 1) {
            # Initialize a temporary string for combination
            $tempString = $splitArray[$i]

            # Combine up to $SkipEvery elements
            for ($j = 1; $j -le $SkipEvery; $j++) {
                if ($i + $j -lt $splitArray.Length) {
                    $tempString += $Delimiter + $splitArray[$i + $j]
                }
            }

            # Add the combined string to the result array
            $resultArray += $tempString
        }

        # Output the result array
        $resultArray
    }
}


