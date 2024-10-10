# REFACTOR: Clean up.
function Test-URLIsValid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string[]] $URL
    )

    process {
        foreach ($u in $URL) {
            $URIObject = [PSCustomObject][ordered]@{
                URL	   = ''
                Valid  = $true
                Host   = ''
            }
            try {
                $casted = [System.Uri]$u
                $URIObject.URL = $u
                $URIObject.Valid = $true
                if(!($casted.Host)){
                    $URIObject.Host = "Undetermined"
                }else{
                    $URIObject.Host = $casted.Host
                }
                $URIObject
            } catch {
                $URIObject.URL = $u
                $URIObject.Valid = $false
                $URIObject.Host = "Invalid"
                $URIObject
            }
        }
    }
}