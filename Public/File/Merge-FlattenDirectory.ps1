# REFACTOR: Code quality.
function Merge-FlattenDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $InputPath,

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [string]
        $DestinationPath = $null,

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [Switch]
        $Force,

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [ValidateSet(1, 2, 3, 4, 5)]
        [int32]
        $DuplicatePadding = 2,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = [System.Collections.Generic.List[String]]@()
    }

    process {
        foreach ($P in $InputPath) {
            if     ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path)         { $List.Add($P.Path) }
            elseif ($P.FullName)     { $List.Add($P.FullName) }
            elseif ($P.PSPath)       { $List.Add($P.PSPath) }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $SourcePath = $_
            $DestPath   = $Using:DestinationPath

            $Duplicates = @{}
            $SourcePath = $SourcePath.TrimEnd('\')
            $DestPath = $DestPath.TrimEnd('\')
            $TempPath = (New-TempDirectory).FullName

            New-Item -ItemType Directory -Force -Path $TempPath | Out-Null

            $Source = [WildcardPattern]::Escape($SourcePath)

            if (!$DestPath) {
                $DestPath = $SourcePath
                Move-Item -Path $Source'\*' -Destination $TempPath -Force

            } else {

                if (Test-Path -LiteralPath $DestPath -PathType Leaf) {
                    throw [System.IO.IOException] "Please provide a valid directory, not a file."
                }

                if (!(Test-PathIsValid -Path $DestPath -Container)) {
                    throw [System.IO.IOException] "Invalid Destination Path. Please provide a valid directory."
                }

                if (Test-PathIsUnsafe -Path $DestPath -Strict) {
                    throw [System.IO.IOException] "The destination path is, or resides in a protected operating system directory."
                }

                Robocopy $Source $TempPath /COPYALL /B /E /R:0 /W:0 /NFL /NDL /NC /NS /NP /MT:48

                New-Item -ItemType Directory -Force -Path $DestPath

            }

            # Grab all files as an Array of FileInfo Objects
            $AllFiles = [IO.DirectoryInfo]::new($TempPath).GetFiles('*', 'AllDirectories')

            foreach ($File in $AllFiles) {

                # If our $Duplicates hashtable already contains the current filename, we have a duplicate.
                if ($Duplicates.Contains($File.Name)) {

                    $PathTemp = Get-ItemProperty -LiteralPath $File
                    $NewName = ('{0}_{1}{2}' -f @(
                            $File.BaseName
                            $Duplicates[$File.Name].ToString().PadLeft($Using:DuplicatePadding, '0')
                            $File.Extension
                        ))

                    $DuplicateCount = 1
                    while ($Duplicates[$NewName]) {
                        $NewName = ('{0}_{1}{2}' -f @(
                                [System.IO.Path]::GetFileNameWithoutExtension($NewName)
                                $DuplicateCount.ToString().PadLeft($Using:DuplicatePadding, '0')
                                [System.IO.Path]::GetExtension($NewName)
                            ))

                        $DuplicateCount++

                        # If we're at a depth of 8, throw. Something is obviously wrong.
                        if ($DuplicateCount -ge 8) {
                            Write-Host "Duplicate count reached limit!" -ForegroundColor Cyan
                            throw [System.Exception] "Duplicate count reached limit."
                            break
                        }
                    }

                    # Finally, rename the file with our new name.
                    $RenamedFile = Rename-Item -LiteralPath $PathTemp.PSPath -PassThru -NewName $NewName

                    # Increment the duplicate counters and pass $File down to be moved.
                    $Duplicates[$File.Name]++
                    $Duplicates[$NewName]++
                    $File = $RenamedFile

                } else {

                    # No duplicates were detected. Add a value of 1 to the duplicates
                    # hashtable to represent the current file. Pass $File down to be moved.
                    $PathTemp = Get-ItemProperty -LiteralPath $File
                    $Duplicates[$File.Name] = 1
                    $File = $PathTemp
                }

                if ($Using:Force) {
                    Move-Item -LiteralPath $File -Destination $DestPath -Force
                } else {
                    try {
                        # Move the file to its appropriate destination. (Non-Force)
                        Move-Item -LiteralPath $File -Destination $DestPath -ErrorAction Stop
                    } catch {
                        # Warn the user that files were skipped because of duplicate filenames.
                        Write-Warning "File already exists in the destination folder. Skipping this file."
                    }
                }
            }
        } -ThrottleLimit $MaxThreads
    }
}