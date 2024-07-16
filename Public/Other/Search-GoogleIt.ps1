# REFACTOR: Code quality. Linux support.
function Search-GoogleIt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]]
        $Query,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Switch]
        $ImageSearch,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Switch]
        $CleanUpFilename,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [ValidateSet('Any', '2mp', '4mp', '6mp', '8mp', '10mp', '12mp', '15mp', '20mp', '40mp', '70mp', IgnoreCase = $true)]
        [String]
        $ImageSearchSize = 'Any',

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [ValidateSet('Any', 'jpg', 'gif', 'png', 'bmp', 'svg', 'webp', 'ico', 'raw', IgnoreCase = $true)]
        [String]
        $ImageFileType = 'Any',

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [String]
        $SiteOrDomain = ''
    )

    process {

        $ImageSearchSizeStr = ($ImageSearchSize -eq 'Any') ? '' : "$($ImageSearchSize.ToLower())"
        $ImageFileTypeStr   = ($ImageFileType -eq 'Any') ? '' : "filetype:$($ImageFileType.ToLower())"
        $SiteOrDomainStr    = ($SiteOrDomain) ? "site:$SiteOrDomain" : ''
        $DefaultBrowserPath = (Get-WindowsDefaultBrowser).ImagePath

        $idx = 1
        foreach ($Q in $Query) {
            if($CleanUpFilename){
                $Q = $Q -replace '_',' '
                $Q = $Q -replace '\.',' '
            }

            $Encoded = [System.Web.HttpUtility]::UrlEncode($Q)

            if($ImageSearch){
                $SearchString = "https://www.google.com/search?as_st=y&tbm=isch&as_q=$Encoded+$SiteOrDomainStr&as_epq=&as_oq=&as_eq=&cr=&as_sitesearch=&safe=images&tbs=isz:lt,islt:$ImageSearchSizeStr,ift:$ImageFileTypeStr"
            }else{
                $SearchString = "https://www.google.com/search?q=$Encoded+$SiteOrDomainStr"
            }

            if($idx -ne 1) { Start-Sleep -Seconds .4 }
            $idx++
            Start-Process $DefaultBrowserPath $SearchString
        }
    }
}
