using namespace System.IO
using namespace System.Management.Automation
using namespace System.Collections.Generic

# Custom class to generate valid values for the RecurseDepth parameter
class RecurseDepthSetting : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return @('Unlimited',0,1,2,3,4,5,6,7,8,9,10)
    }
}
<#
.SYNOPSIS
    Shows files in a directory based on their age (older or newer than specified days).

.DESCRIPTION
    This function retrieves files from the specified directory (and optionally its subdirectories)
    based on their age. It can filter files that are older or newer than a specified number of days.
    The function displays the file size, age, and name of the matching files.

.PARAMETER Directory
    The directory or directories to search for files.

.PARAMETER OlderThan
    The number of days to filter files older than. Mutually exclusive with NewerThan.

.PARAMETER NewerThan
    The number of days to filter files newer than. Mutually exclusive with OlderThan.

.PARAMETER RecurseDepth
    The depth of subdirectories to recurse into. Can be 'Unlimited' or a specific number.

.PARAMETER FileDisplay
    Determines whether to display the full path or only the file name.

.PARAMETER DateMethod
    The date method to use for age calculation: 'LastWrite' (default) or 'Creation'.

.EXAMPLE
    Show-FilesBasedOnAgeInDirectory -Directory "C:\Temp" -OlderThan 30

    Shows files in the "C:\Temp" directory that are older than 30 days.

.EXAMPLE
    Show-FilesBasedOnAgeInDirectory -Directory "C:\Temp" -NewerThan 7 -RecurseDepth 2 -FileDisplay FileOnly

    Shows files in the "C:\Temp" directory and its subdirectories (up to depth 2) that are newer than 7 days,
    displaying only the file names.
#>
function Show-FilesBasedOnAgeInDirectory {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]] $Directory,

        [Parameter(Mandatory,ParameterSetName="Older")]
        [Int32] $OlderThan,

        [Parameter(Mandatory,ParameterSetName="Newer")]
        [Int32] $NewerThan,

        [ValidateSet('Descending','Ascending')]
        [String] $SortOrder = "Descending",

        [Parameter(Mandatory=$false)]
        [ValidateSet([RecurseDepthSetting])]
        [Object] $RecurseDepth = 'Unlimited',

        [ValidateSet('FullPath','FileOnly')]
        [String] $FileDisplay = 'FullPath',

        [ValidateSet('LastWrite','Creation')]
        [String] $DateMethod = "LastWrite"
    )

    begin {
        if($NewerThan -and $OlderThan){
            throw "-NewerThanDays and -OlderThanDays cannnot be used together."
        }
        $DateToday = Get-Date
        $DateCutoff = $DateToday.AddDays(($PSCmdlet.ParameterSetName -eq "Older") ? $OlderThan : $NewerThan)
    }

    process {

        foreach ($Dir in $Directory) {
            [double] $TotalSize = 0

            $ListSplatParams = @{
                Path    =  $Dir
                File    =  $true
                Recurse =  $true
            }
            if($RecurseDepth -ne 'Unlimited'){
                $ListSplatParams['Depth'] = $RecurseDepth
            }
            $List = Get-ChildItem @ListSplatParams

            $FilesList = [List[FileInfo]]@()
            foreach ($File in $List) {
                $DateMeasurement = ($DateMethod -eq 'LastWrite') ? $File.LastWriteTime : $File.CreationTime
                if($DateMeasurement -lt $DateCutoff) { $FilesList.Add($File) }
            }

            [Int] $FilesizeMaxLength = 0
            $FilesObjectList = [List[Object]]@()

            foreach ($File in $FilesList) {

                $FormattedSize = $File.Length | Format-FileSizeAuto -DisplayDecimals

                [String] $FormattedSizeNoLabel = ($FormattedSize -replace '\s[a-z]{1,2}$', '').Trim()
                [String] $FormattedSizeLabel = ($FormattedSize -replace '^[\d\.]{1,1026}\s', '').Trim()
                if($FormattedSizeNoLabel.Length -gt $FilesizeMaxLength){
                    $FilesizeMaxLength = $FormattedSizeNoLabel.Length
                }

                $Filename = ($FileDisplay -eq 'FullPath') ? $File.FullName : $File.BaseName
                $DateMeasurement = ($DateMethod -eq 'LastWrite') ? $File.LastWriteTime : $File.CreationTime
                $Age = (New-TimeSpan -Start $DateMeasurement -End $DateToday).Days

                $AgeCondition = ($PSCmdlet.ParameterSetName -eq "Older") ? ($Age -gt $OlderThan) : ($Age -lt $NewerThan)

                if($AgeCondition){
                    $TotalSize += $File.Length
                    $FileObj = [PSCustomObject]@{
                        Size = $FormattedSizeNoLabel
                        SizeLabel = $FormattedSizeLabel
                        Age = ($Age -as [String]) + " Days"
                        Filename = $Filename
                    }
                    $FilesObjectList.Add($FileObj)
                }
            }

            $FinalObjectList = [List[Object]]@()

            foreach ($F in $FilesObjectList) {
                $FinalSize = "{0:D} {1}" -f $F.Size, $F.SizeLabel

                $DateProperty = ($DateMethod -eq 'LastWrite') ? "Date Modified" : "Date Created"
                $Obj = [PSCustomObject]@{
                    $DateProperty = $F.Age
                    "File Size"   = $FinalSize
                    "File Name"   = $F.Filename
                }

                $FinalObjectList.Add($Obj)
            }

            $ReportedSize = Format-FileSizeAuto -Bytes $TotalSize
            '{0} Files, {1} total' -f $FilesObjectList.Count, $ReportedSize

            $SortProperty = ($DateMethod -eq 'LastWrite') ? "Date Modified" : "Date Created"
            if($SortOrder -eq 'Descending'){
                $FinalObjectList | Sort-Object { [regex]::Replace($_.$SortProperty, '\d+', { $args[0].Value.PadLeft(20) }) } -Descending
            }
            else{
                $FinalObjectList | Sort-Object { [regex]::Replace($_.$SortProperty, '\d+', { $args[0].Value.PadLeft(20) }) }
            }

        }
    }
}