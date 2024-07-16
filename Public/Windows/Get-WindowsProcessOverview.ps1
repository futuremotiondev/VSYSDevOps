# REFACTOR: Clean up and add more features. Cross platform support.
function Get-WindowsProcessOverview {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet('CPU','Name','Path','HandleCount', IgnoreCase = $true)]
        [string] $SortProperty = 'CPU',
        [array] $ExcludeProcess = 'svchost'
    )

    $PList = Get-Process |
             Where-Object { $_.Name -ne $ExcludeProcess } |
             Select-Object -Property Name, CPU,
                 @{Name='Filename';Expression={Split-Path $_.Path -Leaf}},
                 HandleCount |
             Sort-Object -Property $SortProperty -Descending

    return $PList

}