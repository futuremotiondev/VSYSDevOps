function Get-InstalledNodeVersionsCompleter {
    [CmdletBinding()]
    param (
        [Switch] $InsertV
    )

    # Version Parser
    $GetVersions = {
        param (
            [Parameter(Mandatory)] $NVMInput,
            [Switch] $InsertLeadingV
        )

        $NVMInput = $NVMInput -split "\r?\n"

        for ($idx = 0; $idx -lt $NVMInput.Count; $idx++) {
            if([String]::IsNullOrEmpty($NVMInput[$idx])){
                continue
            }

            $nodeVersion = $NVMInput[$idx] -replace '\* ', ''
            $nodeVersion = $nodeVersion -replace '\(([\w\s\-]+)\)', ''
            $nodeVersion = $nodeVersion.Trim()
            if($InsertLeadingV){$nodeVersion = "v$nodeVersion"}
            @($nodeVersion)
        }
    }

    ## Check if NVM is available on the system PATH
    try {
        $NVMCMD = Get-Command nvm -CommandType Application
    } catch {
        $ErrorText = "NVM Node Version Manager isn't installed or available in your PATH environment variable."
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
            'CommandNotFound',
            'CommandNotFound',
            $NVMCMD
        )
        Write-Error $eRecord
        return 2
    }

    $NODE1 = & $NVMCMD list
    $Output = & $GetVersions -NVMInput $NODE1 -InsertLeadingV:$InsertV
    $Output
}