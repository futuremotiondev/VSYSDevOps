function Test-FileIsLocked {

    [cmdletbinding(DefaultParameterSetName = 'Path')]
    param(
        [parameter(
            Mandatory,
            ParameterSetName  = 'Path',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Path,

        [parameter(
            Mandatory,
            ParameterSetName = 'LiteralPath',
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [ValidateScript({
            if ($_ -notmatch '[\?\*]') {
                $true
            } else {
                throw 'Wildcard characters *, ? are not acceptable with -LiteralPath'
            }
        })]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]] $LiteralPath
    )

    begin {
        $ResolvedPathList = [System.Collections.Generic.List[String]]@()
    }

    Process {

        # Resolve paths if necessary.
        $Paths = if($PSCmdlet.ParameterSetName -eq 'Path') { $Path } else { $LiteralPath }
        $Paths | ForEach-Object {
            $ResolvedPaths = Resolve-Path -Path $_
            foreach ($ResolvedPath in $ResolvedPaths) {
                if (Test-Path -Path $ResolvedPath.Path) {
                    $ResolvedPathList.Add($ResolvedPath.Path)
                } else {
                    Write-Warning "$ResolvedPath does not exist on disk."
                }
            }
        }

        ForEach ($Item in $ResolvedPathList) {
            If ([System.IO.File]::Exists($Item)) {
                Try {
                    $FileStream = [System.IO.File]::Open($Item,'Open','Write')
                    $FileStream.Close()
                    $FileStream.Dispose()
                    $IsLocked = $false
                } Catch [System.UnauthorizedAccessException] {
                    $IsLocked = 'AccessDenied'
                } Catch {
                    $IsLocked = $true
                }
                [pscustomobject]@{
                    File = $Item
                    IsLocked = $IsLocked
                }
            }
        }
    }
}