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

    RequiredModules    = @('PwshSpectreConsole', 'PSParallelPipeline')

    RequiredAssemblies = "$PSScriptRoot\Lib\PythonVENVObject.dll",
                         "$PSScriptRoot\lib\Ookii.Dialogs.WinForms.dll",
                         "$PSScriptRoot\lib\Microsoft.Toolkit.Uwp.Notifications.dll",
                         "$PSScriptRoot\lib\Microsoft.Windows.SDK.NET.dll",
                         "$PSScriptRoot\lib\WinRT.Runtime.dll",
                         "$PSScriptRoot\lib\HtmlAgilityPack.dll",
                         "System.Drawing",
                         "System.Windows.Forms",
                         "WindowsFormsIntegration",
                         "PresentationCore",
                         "PresentationFramework",
                         "Microsoft.VisualBasic"

    FunctionsToExport =  'Convert-iTermColorsToINI',
                         'Show-CountdownTimer',
                         'Convert-PlaintextListToArray',
                         'Convert-CommaSeparatedListToPlaintextTable',
                         'Convert-JsonKeysToCommaSeparatedString',
                         'Convert-JsonKeysToLines',
                         'Split-StringByDelimiter',
                         'Split-StringByDelimiterAndCombineLines',
                         'Find-SeparatorInList',
                         'Confirm-NPMPackageExistsInRegistry',
                         'Get-ActiveNodeVersionWithNVM',
                         'Get-InstalledNodeGlobalPackages',
                         'Get-InstalledNodeVersionsCompleter',
                         'Get-InstalledNodeVersionsWithNVM',
                         'Get-LatestNodeWithNVM',
                         'Get-NodeGlobalPackages',
                         'Install-NodeGlobalPackages',
                         'Invoke-NPMCommandsOnNodeVersion',
                         'Uninstall-NodeGlobalPackages',
                         'Update-NodeGlobalPackagesPerVersion',
                         'Test-PathIsLikelyDirectory',
                         'Test-PathIsLikelyFile',
                         'Confirm-PythonFolderIsVENV',
                         'Confirm-PythonPyPiPackageExists',
                         'Get-MinicondaInstallDetails',
                         'Get-PythonVENVDetails',
                         'Install-PythonGlobalPackages',
                         'Save-DotnetAssemblyTemplate',
                         'Save-DotnetConsoleAppTemplate',
                         'Save-LicenseToFolder',
                         'Save-PowershellGalleryNupkg',
                         'Format-Milliseconds',
                         'Convert-AudioToStemsWithDEMUCS',
                         'Copy-WindowsDirectoryStructure',
                         'Copy-WindowsPathToClipboard',
                         'Get-WindowsDefaultBrowser',
                         'Get-WindowsEnvironmentVariable',
                         'Get-WindowsEnvironmentVariables',
                         'Get-WindowsWSLDistributionInfo',
                         'Get-WindowsOpenDirectories',
                         'Get-WindowsOSArchitecture',
                         'Get-WindowsProcessOverview',
                         'Move-FileToFolder',
                         'Move-FileToSubfolder',
                         'Open-WindowsExplorerTo',
                         'Register-WindowsDLLorOCX',
                         'Remove-WindowsInvalidFilenameCharacters',
                         'Rename-RandomizeFilenames',
                         'Request-WindowsAdminRights',
                         'Request-WindowsExplorerRefresh',
                         'Request-ExplorerRefresh',
                         'Restart-WindowsExplorerAndRestore',
                         'Save-FilesToFolderByWord',
                         'Save-FolderToSubfolderByWord',
                         'Save-WindowsOpenDirectories',
                         'Save-RandomDataToFile',
                         'Save-RandomDataToFiles',
                         'Search-GoogleIt',
                         'Set-WindowsFolderIcon',
                         'Split-DirectoryContentsToSubfolders',
                         'Stop-AdobeBackgroundProcesses',
                         'Test-FileIsLocked',
                         'Update-WindowsEnvironmentVariables',
                         'Invoke-OpenFileDialog',
                         'Invoke-VBMessageBox',
                         'Invoke-GUIMessageBox',
                         'Invoke-OokiiInputDialog',
                         'Invoke-OokiiPasswordDialog',
                         'Invoke-OokiiTaskDialog',
                         'Invoke-SaveFileDialog',
                         'Invoke-OpenFolderDialog',
                         'Show-UWPToastNotification',
                         'Test-URLIsValid',
                         'Test-PathIsValid',
                         'ConvertTo-FlatObject',
                         'Get-FirstUniqueFileByDepth',
                         'Format-Bytes',
                         'Format-FileSize',
                         'Format-ObjectSortNumerical',
                         'Get-Enum',
                         'Get-ModulePrivateFunctions',
                         'Get-RandomAlphanumericString',
                         'Get-UniqueNameIfDuplicate',
                         'New-TempDirectory',
                         'Format-StringReplaceDiacritics',
                         'Format-StringRemoveUnusualSymbols',
                         'Save-Base64StringToFile',
                         'Save-FileHash',
                         'Test-WindowsIsAdmin',
                         'Test-DirectoryIsProtected',
                         'Initialize-GitRepo',
                         'Join-StringByNewlinesWithDelimiter',
                         'Get-DevOpsConfigSetting',
                         'Get-DevOpsUserConfigSetting',
                         'Get-GitignoreTemplates',
                         'Use-PythonActivateVENVInFolder',
                         'Update-PythonPackagesInVENV',
                         'Update-PythonPIPInVENV',
                         'Update-PythonPIPGlobally',
                         'Use-PythonFreezeVENVToRequirements',
                         'Use-PythonInstallRequirementsToVENV',
                         'ConvertFrom-HashtableToPSObject',
                         'Get-InstalledNodeNPMVersions',
                         'Get-LicenseTemplates',
                         'Get-LicenseTemplateData',
                         'Get-LicenseTemplate',
                         'Invoke-GoogleTranslate',
                         'Get-IconfontCnData',
                         'Request-WindowsExplorerRefreshAlt',
                         'Invoke-GalleryDLSaveGallery',
                         'Rename-SanitizeFilenamesInFolder',
                         'Rename-SanitizeFilenames',
                         'Stop-AdobeProcesses',
                         'Stop-PwshProcesses',
                         'Confirm-WindowsPathIsProtected',
                         'Format-FileSizeAuto',
                         'Format-NaturalSort',
                         'Show-FilesBasedOnAgeInDirectory',
                         'Convert-WindowsGUIDToPID',
                         'Get-NumberOfProcessorCoresAndThreads',
                         'Edit-RebuildWindowsIconCache',
                         'Save-FoldersInCurrentDirectory',
                         'Get-WindowsProductKey',
                         'Get-WindowsVersionDetails',
                         'Get-AllDriveInfo',
                         'Show-AllBIOSKeyVariables',
                         'Format-String',
                         'Show-HorizontalLineInConsole',
                         'Convert-RegistryFileToPowershellCode',
                         'ConvertTo-UnescapedRegistryStrings',
                         'ConvertTo-RegSZEscaped',
                         'ConvertTo-RegSZUnescaped',
                         'Invoke-Ngen',
                         'Add-NumericSuffixToFile',
                         'Add-StringSuffixToFile',
                         'ConvertTo-FlatDirectory',
                         'Show-SystemOSClockResolution',
                         'Remove-ANSICodesFromString',
                         'Test-DirectoryForPwshFiles',
                         'Test-DirectoryIsEmpty',
                         'New-Log',
                         'Resolve-SymbolicLinks',
                         'Convert-SymbolicLinksToFiles',
                         'Remove-EmptyDirectories',
                         'Test-IsValidGuid',
                         'Resolve-WindowsSIDToIdentifier',
                         'Get-InstalledNodeVersion',
                         'New-ViteProject',
                         'Expand-ArchivesInDirectory',
                         'Get-PythonInstallations'


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

