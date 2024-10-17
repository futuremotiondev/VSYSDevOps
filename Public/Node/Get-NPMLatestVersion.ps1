function Get-NPMLatestVersion {
    [CmdletBinding()]
    param (
        [ValidateSet('SilentlyContinue','Continue','Stop', IgnoreCase = $true)]
        $OnError = "SilentlyContinue"
    )

    $url = "https://registry.npmjs.org/" + 'npm' + '/latest'
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
    }
    catch {
        if($OnError -eq 'SilentlyContinue'){
            return $null
        }
        elseif($OnError -eq 'Continue'){
            Write-Error "Failed to retrieve the latest version of NPM." -ErrorAction Continue
            return $null
        }
        elseif($OnError -eq 'Stop'){
            Write-Error "Failed to retrieve the latest version of NPM." -ErrorAction Stop
        }
    }

    [PSCustomObject]@{
        Name = $response.name
        Version = $response.version
        ID = $response._id
        UpdateCommand = 'npm install -g npm@latest'
    }

}