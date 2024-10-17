@{

    RootModule = "VSYSDevOps.psm1"
    ModuleVersion = '1.0.2'
    GUID = 'ee9012b6-e539-593b-852b-1c68e2f9af70'
    Author = 'Futuremotion'
    CompanyName = 'Futuremotion'
    Copyright = '(c) Futuremotion 2024-2025. All rights reserved.'

    CompatiblePSEditions = @('Core')

    Description = 'Provides development automation functions.'
    PowerShellVersion = '7.1'

    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FileList = @()

    # Leave commented out to import into any host.
    # PowerShellHostName = ''

    RequiredModules    = @('PwshSpectreConsole')

    RequiredAssemblies = "$PSScriptRoot\Lib\PythonVENVObject.dll",
                         "$PSScriptRoot\lib\Ookii.Dialogs.WinForms.dll",
                         "$PSScriptRoot\lib\Microsoft.Toolkit.Uwp.Notifications.dll",
                         "$PSScriptRoot\lib\Microsoft.Windows.SDK.NET.dll",
                         "$PSScriptRoot\lib\WinRT.Runtime.dll",
                        #  "$PSScriptRoot\lib\HtmlAgilityPack.dll",
                         "System.Drawing",
                         "System.Windows.Forms",
                         "WindowsFormsIntegration",
                         "PresentationCore",
                         "PresentationFramework",
                         "Microsoft.VisualBasic"

    FunctionsToExport =  'Add-NumericSuffixToFile',
                         'Add-StringSuffixToFile',
                         'Confirm-NPMPackageExistsInRegistry',
                         'Confirm-PythonFolderIsVENV',
                         'Confirm-PythonPyPiPackageExists',
                         'Confirm-WindowsPathIsProtected',
                         'Convert-AudioToStemsWithDEMUCS',
                         'Convert-CommaSeparatedListToPlaintextTable',
                         'Convert-iTermColorsToINI',
                         'Convert-JsonKeysToCommaSeparatedString',
                         'Convert-JsonKeysToLines',
                         'Convert-PlaintextListToPowershellArray',
                         'Convert-RegistryFileToPowershellCode',
                         'Convert-SymbolicLinksToFiles',
                         'Convert-ToPercentage',
                         'Convert-WindowsGUIDToPID',
                         'ConvertFrom-HashtableToPSObject',
                         'ConvertTo-FlatDirectory',
                         'ConvertTo-FlatObject',
                         'ConvertTo-RegSZEscaped',
                         'ConvertTo-RegSZUnescaped',
                         'ConvertTo-UnescapedRegistryStrings',
                         'Copy-WindowsDirectoryStructure',
                         'Copy-WindowsPathsToClipboard',
                         'Edit-RebuildWindowsIconCache',
                         'Expand-ArchivesInDirectory',
                         'Find-SeparatorInList',
                         'Format-Bytes',
                         'Format-FileSize',
                         'Format-FileSizeAuto',
                         'Format-Milliseconds',
                         'Format-NaturalSort',
                         'Format-ObjectSortNumerical',
                         'Format-String',
                         'Format-StringRemoveUnusualSymbols',
                         'Format-StringReplaceDiacritics',
                         'Get-AllDriveInfo',
                         'Get-Enum',
                         'Get-FirstUniqueFileByDepth',
                         'Get-FullPathWithoutExtension',
                         'Get-IconfontCnData',
                         'Get-InstalledNodeVersion',
                         'Get-NVMLatestNodeVersionInstalled',
                         'Get-MinicondaInstallDetails',
                         'Get-ModulePrivateFunctions',
                         'Get-NPMCommand',
                         'Get-NPMLatestVersion',
                         'Get-NumberOfProcessorCoresAndThreads',
                         'Get-NVMActiveNodeVersion',
                         'Get-NVMCommand',
                         'Get-NVMInstallationDirectory',
                         'Get-NVMInstalledNodeVersions',
                         'Get-NVMInstalledNPMVersions',
                         'Get-NVMNodeInstallationDirectory',
                         'Get-NVMNodeInstallationExe',
                         'Get-NVMNodeNPMVersions',
                         'Get-NVMVersion',
                         'Get-NVMVersionDetails',
                         'Get-PythonInstallations',
                         'Get-PythonVENVDetails',
                         'Get-RandomAlphanumericString',
                         'Get-UniqueNameIfDuplicate',
                         'Get-WindowsDefaultBrowser',
                         'Get-WindowsEnvironmentVariable',
                         'Get-WindowsEnvironmentVariables',
                         'Get-WindowsOpenDirectories',
                         'Get-WindowsOSArchitecture',
                         'Get-WindowsProcessOverview',
                         'Get-WindowsProductKey',
                         'Get-WindowsVersionDetails',
                         'Get-WindowsWSLDistributionInfo',
                         'Install-NodeGlobalPackages',
                         'Install-PythonGlobalPackages',
                         'Invoke-GalleryDLSaveGallery',
                         'Invoke-GoogleTranslate',
                         'Invoke-GUIMessageBox',
                         'Invoke-Ngen',
                         'Invoke-OokiiInputDialog',
                         'Invoke-OokiiPasswordDialog',
                         'Invoke-OokiiTaskDialog',
                         'Invoke-OpenFileDialog',
                         'Invoke-OpenFolderDialog',
                         'Invoke-SaveFileDialog',
                         'Invoke-VBMessageBox',
                         'Join-StringByNewlinesWithDelimiter',
                         'New-Log',
                         'New-TempDirectory',
                         'Open-WindowsExplorerTo',
                         'Register-WindowsDLLorOCX',
                         'Remove-ANSICodesFromString',
                         'Remove-EmptyDirectories',
                         'Remove-WindowsInvalidFilenameCharacters',
                         'Rename-RandomizeFilenames',
                         'Rename-SanitizeFilenames',
                         'Rename-SanitizeFilenamesInFolder',
                         'Request-ExplorerRefresh',
                         'Request-WindowsAdminRights',
                         'Request-WindowsExplorerRefresh',
                         'Request-WindowsExplorerRefreshAlt',
                         'Resolve-SymbolicLinks',
                         'Resolve-WindowsSIDToIdentifier',
                         'Restart-WindowsExplorerAndRestore',
                         'Save-Base64StringToFile',
                         'Save-FileHash',
                         'Save-FilesToFolderByWord',
                         'Save-FoldersInCurrentDirectory',
                         'Save-FolderToSubfolderByWord',
                         'Save-PowershellGalleryNupkg',
                         'Save-RandomDataToFile',
                         'Save-RandomDataToFiles',
                         'Save-WindowsOpenDirectories',
                         'Search-GoogleIt',
                         'Set-WindowsFolderIcon',
                         'Show-AllBIOSKeyVariables',
                         'Show-CountdownTimer',
                         'Show-FilesBasedOnAgeInDirectory',
                         'Show-HorizontalLineInConsole',
                         'Show-NVMNodeGlobalPackages',
                         'Show-SystemOSClockResolution',
                         'Show-UWPToastNotification',
                         'Split-DirectoryContentsToSubfolders',
                         'Split-StringByDelimiter',
                         'Split-StringByDelimiterAndCombineLines',
                         'Stop-AdobeBackgroundProcesses',
                         'Stop-AdobeProcesses',
                         'Stop-PwshProcesses',
                         'Test-DirectoryForPwshFiles',
                         'Test-DirectoryIsEmpty',
                         'Test-DirectoryIsProtected',
                         'Test-FileIsLocked',
                         'Test-IsValidGUID',
                         'Test-PathContainsWildcards',
                         'Test-PathIsLikelyDirectory',
                         'Test-PathIsLikelyFile',
                         'Test-PathIsValid',
                         'Test-URLIsValid',
                         'Test-ValidLiteralPath',
                         'Test-ValidWildcardPath',
                         'Test-WindowsIsAdmin',
                         'Uninstall-NVMNodeGlobalPackages',
                         'Update-NVMGlobalNodePackagesByVersion',
                         'Update-PythonPackagesInVENV',
                         'Update-PythonPIPGlobally',
                         'Update-PythonPIPInVENV',
                         'Update-WindowsEnvironmentVariables',
                         'Use-PythonActivateVENVInFolder',
                         'Use-PythonFreezeVENVToRequirements',
                         'Use-PythonInstallRequirementsToVENV'


    PrivateData = @{
        PSData = @{
            Tags = @('Development', 'Programming', 'DevOps', 'Optimization')
            LicenseUri = 'https://github.com/fmotion1/VSYSDevOps/blob/main/LICENSE'
            ProjectUri = 'https://github.com/fmotion1/VSYSDevOps'
            IconUri = ''
            ReleaseNotes = '1.0.0: (10/31/2023) - Initial Release'
        }
    }
}

