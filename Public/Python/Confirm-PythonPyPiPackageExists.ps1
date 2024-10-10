function Confirm-PythonPyPiPackageExists {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [string]
        $Package
    )

    process {

        $Package = $Package.Trim()
        if ($Package -match '\s') {
            Write-Error "Package name is invalid (Contains Whitespace)"
            return $false
        }

        $npmParams = @{
            Uri = "https://pypi.org/pypi/$Package/json"
            Method = 'GET'
        }

        try {
            Invoke-RestMethod @npmParams
        } catch {
            Write-Host "Package doesn't exist in PyPi's registry."
            return $false
        }

        return $true
    }
}