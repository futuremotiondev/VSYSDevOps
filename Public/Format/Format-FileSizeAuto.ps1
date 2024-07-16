function Format-FileSizeAuto {
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [double] $Bytes,
        [Switch] $DisplayDecimals
    )

    process {
        foreach ($Unit in @('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB')) {
            If ($Bytes -lt 1024) {
                if($DisplayDecimals){
                    return [string]::Format("{0:0.##} {1}", $Bytes, $Unit)
                }
                else{
                    return [string]::Format("{0:0} {1}", $Bytes, $Unit)
                }
            }
            $Bytes /= 1024
        }

        if($DisplayDecimals) {
            return [string]::Format("{0:0.##} YB", $Bytes)
        }
        else {
            return [string]::Format("{0:0} YB", $Bytes)
        }
    }
}