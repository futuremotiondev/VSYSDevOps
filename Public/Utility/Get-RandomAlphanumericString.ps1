function Get-RandomAlphanumericString {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Int32] $Length = 24,

        [ValidateSet("Upper", "Lower", "Mixed", IgnoreCase = $true)]
        [string] $Case = "Mixed",

        [ValidateSet("Letters", "Digits", "Combined", IgnoreCase = $true)]
        [string] $Content = "Combined"
    )

    process {

        # Define character ranges
        $numericRange = 0x30..0x39
        $upperAlphaRange = 0x41..0x5A
        $lowerAlphaRange = 0x61..0x7A

        # Initialize empty character set
        $charSet = @()

        # Combine logic for content and case
        if ($Content -eq "Digits") { $charSet += $numericRange } else {
            if ($Case -eq "Upper" -or $Case -eq "Mixed") { $charSet += $upperAlphaRange }
            if ($Case -eq "Lower" -or $Case -eq "Mixed") { $charSet += $lowerAlphaRange }
        }
        if ($Content -eq "Combined") { $charSet += $numericRange }

        # Generate random string
        $randomChars = Get-Random -InputObject $charSet -Count $Length
        $str = -join [char[]]$randomChars
        return $str
    }
}




# Measure-Command {
#     1..50000 | % { Get-RandomAlphanumericString2 -Length 24 -Case Mixed -Content Combined}
# }