function Convert-AudioToStemsWithDEMUCS {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory,
            ParameterSetName = 'LiteralPath',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $OutputFolder,

        # MDX and MDX_EXTRA seem to perform better with bass heavy
        # music. Drum isolation is cleaner.
        [Parameter(Mandatory=$false)]
        [ValidateSet('htdemucs_ft','mdx','mdx_extra', IgnoreCase = $true)]
        [String]
        $Model = 'mdx_extra',

        [Parameter(Mandatory=$false)]
        [ValidateSet('all','drums','vocals','bass','other', IgnoreCase = $true)]
        [String]
        $Stems = 'all',

        [Parameter(Mandatory=$false)]
        [String]
        $MDXSegment = '88',

        # If you want to use GPU acceleration, you will need at least
        # 3GB of RAM on your GPU for demucs. However, about 7GB of
        # RAM will be required if you use the default arguments. Add
        # --segment SEGMENT to change size of each split. If you only
        # have 3GB memory, set SEGMENT to 8 (though quality may be
        # worse if this argument is too small).
        [Parameter(Mandatory=$false)]
        [String]
        $HTDemucsSegment = '25',

        [Parameter(Mandatory=$false)]
        [ValidateSet('16','24','32', IgnoreCase = $true)]
        [String]
        $BitDepth = '24',

        # SHIFTS performs multiple predictions with random shifts
        # (a.k.a randomized equivariant stabilization) of the input
        # and average them. This makes prediction SHIFTS times slower
        # but improves the accuracy of Demucs by 0.2 points of SDR.
        # The value of 10 was used on the original paper, although 5
        # yields mostly the same gain. It is deactivated by default.
        [Parameter(Mandatory=$false)]
        [String]
        $Shifts = '0',

        [Parameter(Mandatory=$false)]
        [Switch]
        $UseCPU = $false
    )

    begin {
        & "C:\Python\miniconda3\shell\condabin\conda-hook.ps1"
        conda activate demucs

        $ResolvedPathList = [System.Collections.Generic.List[String]]@()
    }

    process {
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

        $ResolvedPathList | ForEach-Object {

            $DFile        = $_
            $DFileBase    = [System.IO.Path]::GetFileNameWithoutExtension($DFile)
            $DTime        = (Get-Date).ToString('MM-dd-yyyy hh-mm-ss')
            $DOutFolder   = "-o", $OutputFolder
            $DModelCaps   = $Model.ToUpper()
            $DOutFilename = "--filename", "($DTime-$DModelCaps-Shifts $Shifts) {track} - {stem}.{ext}"
            # $DOutFull     = "$DOutFolder\$Model\($DTime-$DModelCaps-Shifts $Shifts) $DFileBase - Drums.wav"

            if($Shifts -ne "0") { $DShifts = '--shifts', "$Shifts" } else { $DShifts = '' }

            $DModel       = "-n", "$Model"
            $DStems       = $Stems
            $DBitDepth    = $BitDepth

            if(($Model -eq 'mdx') -or ($Model -eq 'mdx_extra')){
                $DSegment = "--segment", "$MDXSegment"
            }else{
                $DSegment = "--segment", "$HTDemucsSegment"
            }

            $DUseCPU = ($UseCPU -eq $true) ? '-d','cpu' : '-d','cuda'

            if($DBitDepth -eq '16') { $DBitDepth = '' }
            if($DBitDepth -eq '24') { $DBitDepth = '--int24' }
            if($DBitDepth -eq '32') { $DBitDepth = '--float32' }

            if($DStems -eq 'all')    { $DStems = '' }
            if($DStems -eq 'drums')  { $DStems = '--two-stems=drums'  }
            if($DStems -eq 'vocals') { $DStems = '--two-stems=vocals' }
            if($DStems -eq 'bass')   { $DStems = '--two-stems=bass'   }
            if($DStems -eq 'other')  { $DStems = '--two-stems=other'  }

            Write-Host "`$DFile:        " $DFile        -ForegroundColor Green
            Write-Host "`$DFileBase:    " $DFileBase    -ForegroundColor Green
            Write-Host "`$DTime:        " $DTime        -ForegroundColor Green
            Write-Host "`$DOutFolder:   " $DOutFolder   -ForegroundColor Green
            Write-Host "`$DOutFilename: " $DOutFilename -ForegroundColor Green
            Write-Host "`$DOutFull:     " $DOutFull     -ForegroundColor Green
            Write-Host "`$DModel:       " $DModel       -ForegroundColor Green
            Write-Host "`$DStems:       " $DStems       -ForegroundColor Green
            Write-Host "`$DBitDepth:    " $DBitDepth    -ForegroundColor Green
            Write-Host "`$DSegment:     " $DSegment     -ForegroundColor Green
            Write-Host "`$DUseCPU:      " $DUseCPU      -ForegroundColor Green
            Write-Host "`$DShifts:      " $DShifts      -ForegroundColor Green

            & demucs $DModel -v $DOutFolder $DOutFilename $DUseCPU $DShifts $DSegment $DStems $DBitDepth $DFile

        }
    }
}

