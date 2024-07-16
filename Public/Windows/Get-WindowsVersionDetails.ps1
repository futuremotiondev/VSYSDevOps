function Get-WindowsVersionDetails {

    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    $DisplayVersion = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
    $CIMDataToSelect = "OSArchitecture", "Caption", "InstallDate", "CSName", "BootDevice", "SystemDevice", "SystemDrive", "RegisteredUser", "SerialNumber"
    $WindowsCIMInfo = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object $CIMDataToSelect
    $WindowsEdition = $WindowsCIMInfo.Caption -replace 'Microsoft\s', ''
    $WindowsEdition = $WindowsEdition + ($WindowsCIMInfo.OSArchitecture -replace '-bit', '').Insert(0, ' x') + " $DisplayVersion"

    $FullWindowsBuild = ((& cmd /c ver) -replace 'Microsoft Windows \[Version (.*)\]', '$1')[1]
    $ShortWindowsBuild = $FullWindowsBuild -replace '10\.0\.', ''

    Update-TypeData -MemberName OSLanguage -TypeName 'Microsoft.Management.Infrastructure.CimInstance#root/cimv2/win32_operatingsystem' -MemberType ScriptProperty -Value { [System.Globalization.CultureInfo][int]($this.PSBase.CimInstanceProperties['OSLanguage'].Value) } -Force
    $WindowsLanguage = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty OSLanguage
    $WindowsLanguageLCID = $WindowsLanguage.LCID
    $WindowsLanguageName = $WindowsLanguage.Name
    $WindowsLanguageDisplayName = $WindowsLanguage.DisplayName

    [PSCustomObject]@{
        GeneralVersion = "$WindowsEdition (OS Build $ShortWindowsBuild)"
        Edition = $WindowsEdition
        Architecture = $WindowsCIMInfo.OSArchitecture
        FullBuild = $FullWindowsBuild
        ShortBuild = $ShortWindowsBuild
        InstallDate = $WindowsCIMInfo.InstallDate
        ComputerName = $WindowsCIMInfo.CSName
        RegisteredUser = $WindowsCIMInfo.RegisteredUser
        BootDevice = $WindowsCIMInfo.BootDevice
        SystemDevice = $WindowsCIMInfo.SystemDevice
        SystemDrive = $WindowsCIMInfo.SystemDrive
        OSLanguageCode = $WindowsLanguageLCID
        OSLanguageShortName = $WindowsLanguageName
        OSLanguageName = $WindowsLanguageDisplayName
        OSSerialNumber = $WindowsCIMInfo.SerialNumber
    }
}