<#
.SYNOPSIS
    Retrieves information about the Linux distribution running under WSL.

.DESCRIPTION
    The Get-WindowsWSLDistributionInfo function retrieves information about the Linux distribution running under the Windows Subsystem for Linux (WSL).
    It reads the /etc/*-release file in the Linux filesystem to get this information.

.PARAMETER Set
    Specifies the set of information to retrieve.
    'Full' retrieves all information, 'FullNoURLs' retrieves all information except URLs, and 'VersionString' retrieves only the name and version of the distribution.
    The default is 'VersionString'.

.PARAMETER Format
    Specifies the format of the returned information.
    'PSObject' returns a PowerShell custom object, and 'String' returns a string.
    The default is 'String'.

.EXAMPLE
    Get-WindowsWSLDistributionInfo -Set 'Full' -Format 'PSObject'

    This command retrieves all available information about the Linux distribution and returns it as a PowerShell custom object.

.EXAMPLE
    Get-WindowsWSLDistributionInfo -Set 'VersionString' -Format 'String'

    This command retrieves the name and version of the Linux distribution and returns it as a string.

.NOTES
    This function requires WSL to be installed and a Linux distribution to be installed under WSL.
#>
function Get-WindowsWSLDistributionInfo {
    param (
        [ValidateSet('Full','FullNoURLs','VersionString',IgnoreCase = $true)]
        [String] $Set = 'VersionString',

        [ValidateSet('PSObject','String',IgnoreCase=$true)]
        [String] $Format = 'String'
    )

    $VersionData = & wsl cat /etc/*-release

    if($Set -eq 'VersionString'){
        $name = $null
        $version = $null

        foreach ($line in $VersionData) {
            $key, $value = $line.Trim() -split '=', 2
            switch ($key) {
                "NAME" { $name = $value.Trim('"') }
                "VERSION" { $version = $value.Trim('"') }
            }
        }

        if($Format -eq 'PSObject'){
            return [PSCustomObject]@{
                Name = $name
                Version = $version
            }
        } else {
            return "$name $version"
        }
    }

    $excludedKeys = @{
        "DISTRIB_ID" = $true
        "DISTRIB_RELEASE" = $true
        "DISTRIB_CODENAME" = $true
        "DISTRIB_DESCRIPTION" = $true
        "PRETTY_NAME" = $true
        "VERSION_ID" = $true
        "ID" = $true
        "UBUNTU_CODENAME" = $true
    }

    if ($Set -eq 'FullNoURLs') {
        $excludedKeys += @{
            "HOME_URL" = $true
            "SUPPORT_URL" = $true
            "BUG_REPORT_URL" = $true
            "PRIVACY_POLICY_URL" = $true
        }
    }

    $wslObject = [PSCustomObject]@{}

    foreach ($line in $VersionData) {
        $key, $value = $line.Trim() -split '=', 2
        $value = $value.Trim().Trim('"')

        if ($excludedKeys.ContainsKey($key)) {
            continue
        }

        $key = $key -replace '_', ' '
        $titleCaseKey = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
        $titleCaseKey = $titleCaseKey -replace 'Id|Url', { $_.Value.ToUpper() }
        $titleCaseKey = $titleCaseKey -replace 'Version Codename', 'Codename'

        $value = (Get-Culture).TextInfo.ToTitleCase($value.ToLower())
        $value = $value -replace 'Lts ', 'LTS '
        if ($value -match 'Https') { $value = $value.ToLower() }

        $wslObject | Add-Member -NotePropertyName $titleCaseKey -NotePropertyValue $value
    }

    if ($Format -eq 'PSObject') {
        return $wslObject
    } else {
        return ($wslObject.PSObject.Properties | ForEach-Object { "{0}: {1}" -f $_.Name, $_.Value })
    }
}