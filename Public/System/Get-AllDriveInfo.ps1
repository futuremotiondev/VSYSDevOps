
function Get-AllDriveInfo {

    $signature =
@'
[DllImport("kernel32.dll", SetLastError=true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool GetVolumePathNamesForVolumeNameW([MarshalAs(UnmanagedType.LPWStr)] string lpszVolumeName,
        [MarshalAs(UnmanagedType.LPWStr)] [Out] StringBuilder lpszVolumeNamePaths, uint cchBuferLength,
        ref UInt32 lpcchReturnLength);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr FindFirstVolume([Out] StringBuilder lpszVolumeName,
    uint cchBufferLength);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool FindNextVolume(IntPtr hFindVolume, [Out] StringBuilder lpszVolumeName, uint cchBufferLength);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(string lpDeviceName, StringBuilder lpTargetPath, int ucchMax);

'@;
    if (-not ([System.Management.Automation.PSTypeName]'PInvoke.Win32Utils').Type) {
        Add-Type -MemberDefinition $signature -Name Win32Utils -Namespace PInvoke -Using PInvoke, System.Text;
    }

    [UInt32] $lpcchReturnLength = 0;
    [UInt32] $Max = 65535
    $sbVolumeName = New-Object System.Text.StringBuilder($Max, $Max)
    $sbPathName = New-Object System.Text.StringBuilder($Max, $Max)
    $sbMountPoint = New-Object System.Text.StringBuilder($Max, $Max)
    [IntPtr] $volumeHandle = [PInvoke.Win32Utils]::FindFirstVolume($sbVolumeName, $Max)
    do {
        $volume = $sbVolumeName.toString()
        $unused = [PInvoke.Win32Utils]::GetVolumePathNamesForVolumeNameW($volume, $sbMountPoint, $Max, [Ref] $lpcchReturnLength);
        $ReturnLength = [PInvoke.Win32Utils]::QueryDosDevice($volume.Substring(4, $volume.Length - 1 - 4), $sbPathName, [UInt32] $Max);
        if ($ReturnLength) {

            $DriveLetter = ($sbMountPoint.toString() -replace ':\\','')
            $VolumeData = Get-Volume -UniqueId $volume | Select-Object *
            $PartitionData = Get-Partition -DriveLetter $DriveLetter | Select-Object *

            try {
                $DiskData = Get-Disk -Number $PartitionData.DiskNumber | Select-Object *
            }
            catch {
                $DiskData = $null
            }

            [PSCustomObject]@{
                DriveLetter        = $DriveLetter
                DevicePath         = $sbPathName.ToString()
                DiskNumber         = $PartitionData.DiskNumber
                FriendlyName       = $DiskData.FriendlyName
                Model              = $DiskData.Model
                SerialNumber       = $DiskData.SerialNumber
                NumberOfPartitions = $DiskData.NumberOfPartitions
                HealthStatus       = $VolumeData.HealthStatus
                PartitionStyle     = $DiskData.PartitionStyle
                BusType            = $DiskData.BusType
                FirmwareVersion    = $DiskData.FirmwareVersion
                DriveType          = $VolumeData.DriveType
                FileSystem         = $VolumeData.FileSystemType
                LogicalSectorSize  = $DiskData.LogicalSectorSize
                AllocationUnitSize = $VolumeData.AllocationUnitSize
                FriendlyLabel      = $VolumeData.FileSystemLabel
                Capacity           = Format-Bytes -Bytes $VolumeData.Size
                RemainingSpace     = Format-Bytes -Bytes $VolumeData.SizeRemaining
                VolumeName         = $volume
                GptType            = $PartitionData.GptType
                GUID               = $PartitionData.Guid
                IsActive           = $PartitionData.IsActive
                IsBoot             = $PartitionData.IsBoot
                IsDAX              = $PartitionData.IsDAX
                IsHidden           = $PartitionData.IsHidden
                IsOffline          = $PartitionData.IsOffline
                IsReadOnly         = $PartitionData.IsReadOnly
                IsShadowCopy       = $PartitionData.IsShadowCopy
                IsSystem           = $PartitionData.IsSystem
                MbrType            = $PartitionData.MbrType
                Offset             = $PartitionData.Offset
            }

        } else {
            Write-Output "No mountpoint found for: " + $volume
        }
    } while ([PInvoke.Win32Utils]::FindNextVolume([IntPtr] $volumeHandle, $sbVolumeName, $Max));
}

