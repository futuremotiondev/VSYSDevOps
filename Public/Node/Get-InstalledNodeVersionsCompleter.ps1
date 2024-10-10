function Get-InstalledNodeVersionsCompleter {
    [CmdletBinding()]
    param ( [Switch] $InsertV )

    if(-not($env:NVM_HOME)){ return $null }
    $NVMCmd = Get-Command nvm -ErrorAction SilentlyContinue
    if(-not($NVMCmd)){ return $null }

    $NVMOutput = & $NVMCmd list
    $Arr = ($NVMOutput -split "\r?\n")
    $Output = foreach ($Item in $Arr) {
        if([String]::IsNullOrEmpty($Item)){ continue }
        $v = (($Item -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()
        if($InsertV){$v = "v$v"}
        @($v)
    }
    $Output
}