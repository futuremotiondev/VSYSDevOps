function Request-ExplorerRefresh {
    $code = @'
private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
private const uint WM_SETTINGCHANGE   = (uint)0x1a;
private const uint SMTO_ABORTIFHUNG   = (uint)0x0002;
private const uint SHCNE_ASSOCCHANGED = (uint)0x08000000L;
private const uint SHCNF_FLUSH        = (uint)0x1000;
private const uint SHCNF_IDLIST       = (uint)0x0000;

[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
static extern bool SendNotifyMessage(IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam);

[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)]
private static extern IntPtr SendMessageTimeout (IntPtr hWnd, uint Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, IntPtr lpdwResult);

[System.Runtime.InteropServices.DllImport("Shell32.dll")]
private static extern int SHChangeNotify(uint eventId, uint flags, IntPtr item1, IntPtr item2);

public static void Refresh()  {
    SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
    SHChangeNotify(0x8000000, SHCNF_IDLIST, IntPtr.Zero, IntPtr.Zero);
    SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, IntPtr.Zero, IntPtr.Zero);
    SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
}
'@

    Add-Type -MemberDefinition $code -Namespace Win32Refresh -Name Explorer
    [Win32Refresh.Explorer]::Refresh()
}