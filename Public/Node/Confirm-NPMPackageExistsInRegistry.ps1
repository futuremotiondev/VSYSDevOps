function Confirm-NPMPackageExistsInRegistry {
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [string]
        $Package
    )

    process {

        $Package = $Package.Trim()
        if ($Package -match '\s') {
            Write-Host "Package name is invalid (Contains Whitespace)"
            return $false
        }

        $npmParams = @{
            Uri = 'https://registry.npmjs.org/' + $Package
            Method = 'GET'
            Headers = @{
                'Accept' = 'application/vnd.npm.install-v1+json; q=1.0, application/json; q=0.8, */*'
            }
        }

        try {
            Invoke-RestMethod @npmParams
        } catch {
            Write-Host "Package doesn't exist in the NPM registry"
            return $false
        }

        $true
    }
}
