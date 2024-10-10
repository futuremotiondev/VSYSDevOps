# REFACTOR: Linux support, code quality, pipeline
function Get-WindowsDefaultBrowser {
    [CmdletBinding()]
    param ()

    try {
        $BrowserRegPath     = 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice'
        $DBrowserProgID     = (Get-Item $BrowserRegPath | Get-ItemProperty).ProgId
        $Command            = Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\$DBrowserProgID\shell\open\command" -ErrorAction Stop
        $DBrowserCommand    = $Command.'(default)'
        $DBrowserImagePath  = ([regex]::Match($DBrowserCommand,'\".+?\"')).Value
        $DBrowserImagePath  = $DBrowserImagePath.Trim('"')
        $DBrowserImage      = [System.IO.Path]::GetFileName($DBrowserImagePath)

    } catch {
        throw "Couldn't determine default browser."
    }

    switch ($DBrowserProgID) {
        'IE.HTTP' {
            $DBrowserName = "Internet Explorer"
        }
        'ChromeHTML' {
            $DBrowserName = "Chrome"
        }
        'MSEdgeHTM' {
            $DBrowserName = "Microsoft Edge"
        }
        'FirefoxURL-308046B0AF4A39CB' {
            $DBrowserName = "Firefox"
        }
        'FirefoxURL-E7CF176E110C211B' {
            $DBrowserName = "Firefox"
        }
        'AppXq0fevzme2pys62n3e0fbqa7peapykr8v' {
            $DBrowserName = "Microsoft Edge"
        }
        'OperaStable' {
            $DBrowserName = "Opera"
        }
        default{
            $DBrowserName = "Unknown Browser"
        }
    }

    [PSCustomObject]@{
        Name           = $DBrowserName
        ProgID	       = $DBrowserProgID
        Image	       = $DBrowserImage
        ImagePath      = $DBrowserImagePath
        DefaultCommand = $DBrowserCommand
    }
}