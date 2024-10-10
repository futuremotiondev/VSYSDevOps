<#
.SYNOPSIS
Downloads packages from the PowerShell Gallery.

.DESCRIPTION
The Save-PowershellGalleryNupkg function downloads packages from the PowerShell Gallery using either an array of links or a text file containing links. The downloaded packages are saved to the specified output directory.

.PARAMETER GalleryLinks
An array of PowerShell Gallery package links.

.PARAMETER GalleryTextFile
A text file containing PowerShell Gallery package links.

.PARAMETER OutputDirectory
The directory where the downloaded packages will be saved.

.PARAMETER MaxThreads
The maximum number of concurrent downloads. Defaults to 6.

.EXAMPLE
Save-PowershellGalleryNupkg -GalleryLinks 'https://www.powershellgallery.com/packages/SpeculationControl/1.0.18' -OutputDirectory 'C:\Downloads'

This example downloads the package at 'https://www.powershellgallery.com/packages/SpeculationControl/1.0.18' and saves it to 'C:\Downloads'.

.EXAMPLE
Save-PowershellGalleryNupkg -GalleryLinks 'https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.1.4', 'https://www.powershellgallery.com/packages/PackageManagement/1.4.8.1' -OutputDirectory 'C:\Downloads' -MaxThreads 4

This example downloads the packages at 'https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.1.4' and 'https://www.powershellgallery.com/packages/PackageManagement/1.4.8.1' concurrently with a maximum of 4 threads and saves them to 'C:\Downloads'.

.EXAMPLE
Save-PowershellGalleryNupkg -GalleryTextFile 'C:\Links.txt' -OutputDirectory 'C:\Downloads'

This example reads the links from 'C:\Links.txt', downloads the corresponding packages, and saves them to 'C:\Downloads'.

.EXAMPLE
Save-PowershellGalleryNupkg -GalleryTextFile 'C:\MoreLinks.txt' -OutputDirectory 'C:\MoreDownloads' -MaxThreads 8

This example reads the links from 'C:\MoreLinks.txt', downloads the corresponding packages concurrently with a maximum of 8 threads, and saves them to 'C:\MoreDownloads'.

.NOTES
Author: Futuremotion
Website: https://www.github.com/fmotion1
#>
function Save-PowershellGalleryNupkg {
    param (
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='Array')]
        [String[]] $GalleryLinks,
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='TextFile')]
        [String] $GalleryTextFile,
        [Parameter(Mandatory,ParameterSetName='Array')]
        [Parameter(Mandatory,ParameterSetName='TextFile')]
        [String] $OutputDirectory,
        [Int32] $MaxThreads = 6
    )

    begin {

        if (-not (Test-Path $OutputDirectory)) {
            New-Item -Path $OutputDirectory -ItemType Directory -Force
        }

        if($PSCmdlet.ParameterSetName -eq 'TextFile') {
            $GalleryLinks = Get-Content $GalleryTextFile
        }

        $List = [System.Collections.Generic.List[string]]@()
    }

    process {
        foreach ($Link in $GalleryLinks) {
            $reGallery = '^https:\/\/www\.powershellgallery\.com\/packages\/[a-zA-Z0-9\.\-_ ]+\/[a-zA-Z0-9\.\-_]+$'
            $reGalleryNoProtocol = '^(?:https:\/\/)?www\.powershellgallery\.com\/packages\/[a-zA-Z0-9\.\-_ ]+\/[a-zA-Z0-9\.\-_]+$'
            if ($Link -match $reGallery) {
                $List.Add($Link)
            } 
            elseif($Link -match $reGalleryNoProtocol) {
                $NewLink = 'https://' + $Link
                $List.Add($NewLink)
            }
            else{
                Write-Warning "A link was passed that doesn't appear to be a PowershellGallery package URL."
            }
        }
    }
    
    end {

        $List | ForEach-Object -Parallel {

            $PackageURL = $_

            $PackageName, $PackageVersion = $PackageURL -split '/' | Select-Object -Last 2
            $DownloadUrl = "https://www.powershellgallery.com/api/v2/package/$PackageName/$PackageVersion"
    
            try {
                Invoke-WebRequest -Uri $DownloadUrl -OutFile $Using:OutputDirectory
                Write-Host "Downloaded: $PackageName.$PackageVersion"
            } catch {
                Write-Error "Failed to download $PackageName.$PackageVersion"
            }

        } -ThrottleLimit $MaxThreads
    }
}