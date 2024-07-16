function Get-RandomAlphanumericString {
	[CmdletBinding()]
	param (
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Int32] $Length = 24,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $ToUpper
	)

    process {

        $numericRange = 0x30..0x39
        $upperAlphaRange = 0x41..0x5A
        $lowerAlphaRange = 0x61..0x7A
        $combinedRange = $numericRange + $upperAlphaRange + $lowerAlphaRange
        $randomChars = $combinedRange | Get-Random -Count $Length
        $str = -join ($randomChars | ForEach-Object { [char]$_ })

        if ($ToUpper) { $str.ToUpper() } else { $str }
    }
}