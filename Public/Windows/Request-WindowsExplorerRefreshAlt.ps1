function Request-WindowsExplorerRefreshAlt {
    param ()

$code = @"
using System;
namespace VSYS
{
    public static class Util
    {

        public static void RefreshExplorer(){

            Console.WriteLine("Refreshing Explorer");

            Guid CLSID_ShellApplication = new Guid("13709620-C279-11CE-A49E-444553540000");
            Type shellApplicationType = Type.GetTypeFromCLSID(CLSID_ShellApplication, true);

            object shellApplication = Activator.CreateInstance(shellApplicationType);
            object windows = shellApplicationType.InvokeMember("Windows", System.Reflection.BindingFlags.InvokeMethod, null, shellApplication, new object[] { });

            Type windowsType = windows.GetType();
            object count = windowsType.InvokeMember("Count", System.Reflection.BindingFlags.GetProperty, null, windows, null);
            for (int i = 0; i < (int)count; i++)
            {
                object item = windowsType.InvokeMember("Item", System.Reflection.BindingFlags.InvokeMethod, null, windows, new object[] { i });
                if (item != null) {
                    Type itemType = item.GetType();
                    // only refresh windows explorer
                    string itemName = (string)itemType.InvokeMember("Name", System.Reflection.BindingFlags.GetProperty, null, item, null);
                    if ((itemName == "Windows Explorer") || (itemName == "File Explorer")) {
                        itemType.InvokeMember("Refresh", System.Reflection.BindingFlags.InvokeMethod, null, item, null);
                    }
                }
            }
        }
    }
}
"@
    Add-Type -TypeDefinition $code -Language CSharp
    Invoke-Expression "[VSYS.Util]::RefreshExplorer()"
}