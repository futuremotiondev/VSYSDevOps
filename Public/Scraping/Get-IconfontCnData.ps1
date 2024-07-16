using namespace System.Collections.Generic

function Get-IconfontCnData {
    [OutputType([List[psobject]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]] $InputURL,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Switch] $TranslateNames
    )

    begin {

        $ValidIconfontURLs = @()

        & "D:\Dev\Powershell\VSYSModules\VSYSDevOps\python_venv\Selenium\Scripts\Activate.ps1"
    }

    process {
        foreach ($URL in $InputURL) {
            if ($URL -notmatch '^https://www\.iconfont\.cn/collections/') {
                Write-Error "Invalid URL: $URL. Skipping."
                continue
            }

            if ($URL -notmatch '&cid=\d+$') {
                Write-Error "Invalid URL: $URL. Missing '&cid=' parameter. Skipping."
                continue
            }

            $ValidIconfontURLs += $URL

        }
    }

    end {

        $AllProjectsSVGCollections = [List[psobject]]@()

        $ValidIconfontURLs | ForEach-Object {

            $URL = $_
            # $ProjectID = $URL -replace '^.*&cid=(\d+)$', '$1'

            ($WebContent = & python 'D:\Dev\Powershell\VSYSModules\VSYSDevOps\python_scripts\selenium\print_icon_list.py' $URL) # 2>&1 | out-null
            #Write-Host -f Green "`$WebContent:" $WebContent
            $htmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
            $htmlDoc.LoadHtml($WebContent)
            $IconULList = $htmlDoc.DocumentNode.SelectSingleNode("//ul[@class='block-icon-list']")
            $singleProjectIcons = [System.Collections.Generic.List[psobject]]@()


            foreach ($ListItem in $IconULList.SelectNodes("./li")) {
                [HtmlAgilityPack.HtmlNode]$Item = $ListItem
                $svgContent = $Item.SelectSingleNode(".//div[@class='icon-twrap']/svg").OuterHtml
                $svgName = $Item.SelectSingleNode(".//span[@class='icon-name']/span").InnerText

                $iconObj = [PSCustomObject]@{
                    SVG = $svgContent
                    Name = $svgName
                }
                $singleProjectIcons.Add($iconObj)
            }

            $AllProjectsSVGCollections.Add($singleProjectIcons)

        }

        if($TranslateNames) {

            $TranslatedCollections = [System.Collections.Generic.List[psobject]]@()

            foreach ($SVGCollection in $AllProjectsSVGCollections) {

                $TranslatedCollection = [System.Collections.Generic.List[psobject]]@()
                foreach ($SVGIcon in $SVGCollection){
                    $TranslatedIcoName = Invoke-GoogleTranslate -InputObject ($SVGIcon.Name) -SourceLanguage 'Chinese (Simplified)' -TargetLanguage English
                    $TranslatedIcoName = $TranslatedIcoName.Translation
                    $TranslatedIconObject = [PSCustomObject]@{
                        SVG = $SVGIcon
                        Name = $TranslatedIcoName
                    }
                    $TranslatedCollection.Add($TranslatedIconObject)
                }

                $TranslatedCollections.Add($TranslatedCollection)
            }

            return $TranslatedCollections

        }

        $AllProjectsSVGCollections

    }
}

# Get-IconfontCnData -InputURL 'https://www.iconfont.cn/collections/detail?spm=a313x.collections_index.i1.d9df05512.55643a81ZirQWp&cid=9167'
