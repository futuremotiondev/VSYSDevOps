function Test-FileIsLocked {

    [cmdletbinding(DefaultParameterSetName = 'Path')]

    param(

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Path"
        )]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String[]] $Path,

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath"
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [String[]] $LiteralPath

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