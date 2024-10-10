<#
.SYNOPSIS
    Writes multiple random files to disk based on given specifications.

.DESCRIPTION
    Writes multiple random files to disk based on given specifications.
    All written data is completely random and utilizes
    System.Security.Cryptography.RNGCryptoServiceProvider for content.

.PARAMETER OutputPath
    The path to save all generated random data files.

.PARAMETER FilesizeMin
    The minimum filesize for each generated file.

.PARAMETER FilesizeMax
    The maximum filesize for each generated file.

.PARAMETER Unit
    The memory unit referenced by FilesizeMin / FilesizeMax
    Must be: 'Bytes','KB','MB','GB','TB'
    For example, a FilesizeMin of 1 and FilesizeMax of 2 with a unit
    of 'MB' will write random files with a filesize between 1 and 2 MB.

.PARAMETER NumberOfFiles
    The number of random files to generate in the target directory.

.PARAMETER FilenameLengthMin
    The minimum filename length of each generated file excluding the extension.

.PARAMETER FilenameLengthMax
    The maximum filename length of each generated file excluding the extension.

.PARAMETER FileExtensions
    An array of possible file extensions to be used when generating files.
    Leave this as one string to restrict to a single extension. A default
    random set of filenames has been hardcoded. This parameter is optional.

.PARAMETER RandomFileExtensions
    When enabled, all resulting file extensions will be completely random.
    This overrides the FileExtensions parameter.

.EXAMPLE
    Save-RandomDataToFiles -OutputPath 'C:\Dev\Testing\Random' -FilesizeMin 20 -FilesizeMax 60 -Unit 'KB' -NumberOfFiles 20
    > This will generate 20 files between a filesize of 20-60KB in C:\Dev\Testing\Random

.EXAMPLE
    Save-RandomDataToFiles -OutputPath 'C:\Dev\Testing\Random' -FilesizeMin 1 -FilesizeMax 2 -Unit 'GB' -NumberOfFiles 5 -FileExtensions 'iso','bin'
    > This will generate 5 files between a filesize of 1-2GB in C:\Dev\Testing\Random with a file extension of either .iso or .bin.

.EXAMPLE
    Save-RandomDataToFiles -OutputPath 'C:\Dev\Testing\Random' -FilesizeMin 10 -FilesizeMax 20 -Unit 'MB' -NumberOfFiles 50 -RandomFileExtensions
    > This will generate 50 files between a filesize of 10-20MB in C:\Dev\Testing\Random with completely random file extensions.

.INPUTS
    String          (OutputPath, Unit)
    Decimal         (FilesizeMin, FilesizeMax)
    Int32           (NumberOfFiles, FilenameLengthMin, FilenameLengthMax)
    String Array    (FileExtensions)
    Switch          (RandomFileExtensions)

.OUTPUTS
    Nothing.

.NOTES
    Name: Save-RandomDataToFiles
    Author: Visusys
    Release: 1.0.0
    License: MIT License
    DateCreated: 2021-12-02

.LINK
    https://github.com/visusys

.LINK
    Save-RandomDataToFile

#>
function Save-RandomDataToFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]
        $OutputPath,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [decimal]
        $FilesizeMin,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [decimal]
        $FilesizeMax,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('Bytes','KB','MB','GB','TB', IgnoreCase = $true)]
        [string]
        $Unit,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $NumberOfFiles = 20,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $FilenameLengthMin = 10,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $FilenameLengthMax = 25,

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [String[]]
        $FileExtensions = @('exe','jpg','png','dll','gif','ttf','doc','otf','txt'),

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [Switch]
        $RandomFileExtensions,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $OutputPath) {
            if     ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $DestPath           = $_
            $FExtensions        = $Using:FileExtensions
            $FExtensionsNum     = $FExtensions.Count
            $FExtensionsRnd     = $Using:RandomFileExtensions
            $NumFilesToGenerate = $Using:NumberOfFiles
            $FSizeMin           = $Using:FilesizeMin
            $FSizeMax           = $Using:FilesizeMax
            $FnLengthMin        = $Using:FilenameLengthMin
            $FnLengthMax        = $Using:FilenameLengthMax
            $FnUnit             = $Using:Unit

            for ($i = 0; $i -lt $NumFilesToGenerate; $i++) {

                $CalculatedFilesize = Get-Random -Minimum $FSizeMin -Maximum $FSizeMax

                if($FExtensionsRnd){
                    $FinalExtension = Get-RandomAlphanumericString -Length 3
                }else{
                    $FinalExtension = $FExtensions[(Get-Random -Minimum 0 -Maximum $FExtensionsNum)]
                }

                if($FnLengthMin -gt $FnLengthMax){
                    throw [System.Exception] "Minimum file length is greater than Maximum. Aborting."
                }

                if($FnLengthMin -eq $FnLengthMax){
                    $FinalFnLength = $FnLengthMin
                }else{
                    $FinalFnLength = Get-Random -Minimum $FnLengthMin -Maximum $FnLengthMax
                }

                $RandomData = @{
                    OutputPath     = $DestPath
                    Filesize       = $CalculatedFilesize
                    Unit           = $FnUnit
                    FileExtension  = $FinalExtension
                    FilenameLength = $FinalFnLength
                }

                Save-RandomDataToFile @RandomData
            }
        } -ThrottleLimit $MaxThreads
    }
}