
function ConvertTo-FlatDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [String[]] $Path,
        [int32] $DuplicatePadding = 2,
        [String] $PaddingSeparator = " ",
        [Int32] $MaxThreads = 14
    )

    begin {
        $PathList = [System.Collections.Generic.List[String]]@()
    }


    process {
        foreach ($Folder in $Path) {
            $PathList.Add($Folder)
        }
    }

    end {

        if($PathList.Count -eq 1){
            $MaxThreads = 1
        }


        $PathList | ForEach-Object -Parallel {

            $Directory = $_
            $DuplicatePadding = $Using:DuplicatePadding
            $PaddingSeparator = $Using:PaddingSeparator

            if (Test-DirectoryIsProtected -Path $Directory) {
                throw "Passed path is a protected operating system directory or within one. ($Directory)"
            }

            $TempPath = (New-TempDirectory).FullName
            Move-Item -Path $Directory'\*' -Destination $TempPath -Force | Out-Null
            $AllFiles = [IO.DirectoryInfo]::new($TempPath).GetFiles('*', 'AllDirectories')

            $AllFiles | ForEach-Object -Parallel {

                $DuplicatePadding = $Using:DuplicatePadding
                $PaddingSeparator = $Using:PaddingSeparator

                $DestinationPath = $Using:Directory
                $Filename = [System.IO.Path]::GetFileName($_)
                $FilepathInTemp = $_.FullName

                $DestFilepath = Join-Path $DestinationPath -ChildPath $Filename
                $DestFilepath = Get-UniqueNameIfDuplicate -LiteralPath $DestFilepath

                Move-Item -LiteralPath $FilepathInTemp -Destination $DestFilepath -Force | Out-Null

            } -ThrottleLimit 8

            $TempPath | Remove-Item -Recurse -Force

        } -ThrottleLimit $MaxThreads
    }
}
