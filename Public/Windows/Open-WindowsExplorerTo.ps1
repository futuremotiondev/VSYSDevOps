function Open-WindowsExplorerTo {
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
                throw 'Wildcards are not acceptable with -LiteralPath'
            }
        })]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]] $LiteralPath,

        [parameter(
            Mandatory,
            ParameterSetName = 'File',
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [Alias('Filename')]
        [String] $File,

        [parameter(
            Mandatory,
            ParameterSetName = 'Clipboard',
            ValueFromPipelineByPropertyName
        )]
        [Switch] $Clipboard,

        [int] $DelayMS = 0,
        [Switch] $Minimized
    )

    begin {
        # Create a list to store resolved paths.
        $ResolvedPathList = [System.Collections.Generic.List[String]]@()
    }

    process {

        [string]$Content = $null
        switch ($PSCmdlet.ParameterSetName) {
            'File' {
                if(-not(Test-Path -Path $File -PathType Leaf)){
                    throw "-File passed doesn't exist ($File)."
                }
                else {
                    $ResolvedFile = Resolve-Path -Path $File
                    $Content = (Get-Content -LiteralPath $ResolvedFile) -join "`r`n"
                }
            }
            'Clipboard' {
                $Content = Get-Clipboard -Raw
            }
            { $_ -eq 'File' -or $_ -eq 'Clipboard' } {
                $Content = $Content.Trim()
                $Paths = $Content -split "`r`n" | Where-Object { ![string]::IsNullOrWhiteSpace($_) }
                break
            }
            default {
                $Paths = if($PSCmdlet.ParameterSetName -eq 'Path') { $Path } else { $LiteralPath }
            }
        }

        $Paths | ForEach-Object {
            if(Test-Path -Path $_ -PathType Container){
                $ResolvedPaths = Resolve-Path -Path $_
                foreach ($ResolvedPath in $ResolvedPaths) {
                    if (Test-Path -Path $ResolvedPath.Path) {
                        $ResolvedPathList.Add($ResolvedPath.Path)
                    } else {
                        Write-Warning "$ResolvedPath does not exist on disk."
                    }
                }
            }
        }

        $ResolvedPathList | ForEach-Object {
            if($DelayMS -ne 0){
                Start-Sleep -Milliseconds $DelayMS
            }

            if($Minimized) {
                Start-Process $_ -WindowStyle Minimized | Out-Null
            } else{
                Start-Process $_ | Out-Null
            }
        }
    }

    end {}
}