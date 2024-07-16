function Format-StringTitleCase {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string[]] $String,
        [switch] $ToLowerFirst
    )

    begin {
        $TI = (Get-Culture).TextInfo
    }

    process {
        foreach ($s in $String) {
            if ($ToLowerFirst) {
                $ReturnString = $TI.ToTitleCase($s.ToLower())
            } else {
                $ReturnString = $TI.ToTitleCase($s)
            }
            $ReturnString
        }
    }

    end {}
}
