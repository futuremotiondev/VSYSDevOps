function Invoke-GalleryDLSaveGallery {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]] $InputURLs,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String] $OutputFolder
    )

    begin {

        $VenvFolder = Join-Path -Path $env:FM_PY_VENV -ChildPath 'GalleryDL'
        $ScriptsFolder = Join-Path -Path $VenvFolder -ChildPath 'Scripts'
        $ActivateScript = [System.IO.Path]::Combine($VenvFolder, 'Scripts', 'Activate.ps1')
        & $ActivateScript

        if(-not(Test-Path -LiteralPath $OutputFolder -PathType Container)){
            New-Item -Path $OutputFolder -ItemType Directory | Out-Null
        }

        $GalleryDL = Get-Command "$ScriptsFolder\gallery-dl.exe"

    }

    process {
        foreach ($URL in $InputURLs) {
            $Params = '-d', $OutputFolder, $URL
            & $GalleryDL $Params
        }
    }

    end {
        & deactivate
    }

}


