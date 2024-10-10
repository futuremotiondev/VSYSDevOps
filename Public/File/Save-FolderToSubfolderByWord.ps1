function Save-FolderToSubfolderByWord {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Folders,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [ValidateSet(1,2,3)]
        $NumWords = 1
    )

    process {
        foreach ($Item in $Folders) {

            $FolderName = Split-Path $Item -Leaf
            $ParentDir = Split-Path $Item -Parent
            $FolderNameArr = $FolderName.Split(" ")

            if($FolderNameArr.Count -lt $NumWords){ continue }

            $NewChild = ($FolderNameArr | Select -First $NumWords) -join " "
            $DestPath = Join-Path $ParentDir -ChildPath $NewChild

            if($DestPath -eq $Item){ continue; }

            if(!(Test-Path $DestPath -PathType Container)){
                [IO.Directory]::CreateDirectory($DestPath) | Out-Null
            }

            [System.IO.Directory]::Move($Item, (Join-Path $DestPath $FolderName))
        }
    }
}