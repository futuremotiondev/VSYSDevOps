
function Request-WindowsExplorerRefresh {
    param (
        [switch] $SendF5,
        [Int32] $SendF5Delay=150
    )

    $shellApplication = New-Object -ComObject Shell.Application
    $windows = $shellApplication.Windows()
    $count = $windows.Count()

    foreach( $i in 0..($count-1) ) {
        $item = $windows.Item( $i )
        if( $item.Name() -like '*Explorer*' ) {
            $item.Refresh()
        }
    }

    if($SendF5){
        $wshell = New-Object -ComObject wscript.shell;
        Start-Sleep -Milliseconds $SendF5Delay
        $wshell.SendKeys("{F5}")
        Start-Sleep -Milliseconds $SendF5Delay
        $wshell.SendKeys("{F5}")
    }
}