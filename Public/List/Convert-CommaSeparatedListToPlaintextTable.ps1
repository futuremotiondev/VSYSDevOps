function Convert-CommaSeparatedListToPlaintextTable {
    param (
        [string] $InputText,
        [Int32] $SpacesBetweenWords = 5,
        [Int32] $WordsPerRow = 5
    )

    # Split the input text by commas
    $words = $InputText -split ','

    # Determine the number of rows based on the total words and words per row
    $totalRows = [math]::Ceiling($words.Length / $wordsPerRow)

    # Calculate padding for each column
    $columnWidths = for ($i = 0; $i -lt $wordsPerRow; $i++) {
            ($words | Select-Object -Index ([int[]](0..($words.Count - 1)) | Where-Object { $_ % $wordsPerRow -eq $i })) | Measure-Object -Property Length -Maximum | Select-Object -ExpandProperty Maximum
    }

    # Generate the table
    for ($row = 0; $row -lt $totalRows; $row++) {
        $line = ""
        for ($col = 0; $col -lt $wordsPerRow; $col++) {
            $index = $row * $wordsPerRow + $col
            if ($index -lt $words.Length) {
                $word = $words[$index]
                # Add the word and padding spaces, adjust the padding based on the longest word in the column
                $padding = $columnWidths[$col] - $word.Length + $SpacesBetweenWords # Add extra spaces as per requirement
                $line += $word + (' ' * $padding)
            }
        }
        # Output the line
        $line.TrimEnd()
    }
}

