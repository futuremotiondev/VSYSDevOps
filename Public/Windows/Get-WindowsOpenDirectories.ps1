# REFACTOR: Linux Support, Better code quality.
function Get-WindowsOpenDirectories {
    $oWindows = (New-Object -ComObject 'Shell.Application').Windows()
    $oWindows | ForEach-Object {
        $path =  ($_.LocationURL).TrimStart('file:///')
        $path = [System.Web.HttpUtility]::UrlDecode($path)
        $path
    }
}