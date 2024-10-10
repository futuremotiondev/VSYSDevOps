function Confirm-PythonFolderIsVENV {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]] $Folder
    )

    process {
        foreach ($F in $Folder) {
            $pyvenvcfg = [System.IO.Path]::Combine($F, 'pyvenv.cfg')
            if(Test-Path -LiteralPath $pyvenvcfg -PathType Leaf){
                $true
            } else {
                $false
            }
        }
    }
}