function Convert-RegistryFileToPowershellCode {

    [CmdLetBinding()]
    param(
        [Parameter(ValueFromPipeline,Mandatory,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath,
        [string] $Encoding = "utf8"
    )

    begin {
        $hive = @{
            "HKEY_CLASSES_ROOT"   = "HKCR:"
            "HKEY_CURRENT_CONFIG" = "HKCC:"
            "HKEY_CURRENT_USER"   = "HKCU:"
            "HKEY_LOCAL_MACHINE"  = "HKLM:"
            "HKEY_USERS"          = "HKU:"
        }
        [system.boolean]$isfolder = $false
        $addedpath = @()
    }

    process {

        if (Test-Path -LiteralPath $LiteralPath -PathType Container) {
            $Files = (Get-ChildItem -LiteralPath $LiteralPath -Recurse -Force -File -Filter "*.reg").FullName
            $isfolder = $true
        }
        else {
            if ($LiteralPath.EndsWith(".reg")) {
                $Files = $LiteralPath
            }
        }

        foreach ($File in $Files) {
            $Commands = @()
            foreach ($root in $hive.keys) {
                if ((Get-Content -Path $file -Raw) -match $root -and $hive[$root] -notin ('HKCU:', 'HKLM:')) {
                    $commands += "New-PSDrive -Name $($hive[$root].replace(':', '')) -PSProvider Registry -Root $root"
                }
            }
            [string]$text = $nul
            $FileContent = Get-Content $File | where { ![string]::IsNullOrWhiteSpace($_) } | % { $_.Trim() }
            $joinedlines = @()
            foreach ($line in $FileContent) {
                if ($line.EndsWith("\")) {
                    $text = $text + ($line -replace "\\$").trim()
                }
                else {
                    $joinedlines += $text + $line
                    [string]$text = $nul
                }
            }

            foreach ($joinedline in $joinedlines) {
                if ($joinedline -match "\[HKEY(.*)+\]") {
                    $key = $joinedline -replace '\[-?|\]'
                    $hivename = $key.split('\')[0]
                    $key = '"' + ($key -replace $hivename, $hive.$hivename) + '"'
                    if ($joinedline.StartsWith("[-HKEY")) {
                        $Commands += 'Remove-Item -Path {0} -Force -Recurse' -f $key
                    }
                    else {
                        if ($key -notin $addedpath) {
                            $Commands += 'New-Item -Path {0} -ErrorAction SilentlyContinue | Out-Null' -f $key
                            $addedpath += $key
                        }
                    }
                }
                elseif ($joinedline -match "`"([^`"=]+)`"=") {

                    [System.Boolean]$Delete = $false

                    $name = ($joinedline | Select-String -Pattern "`"([^`"=]+)`"").Matches.Value | Select-Object -First 1

                    switch ($joinedline) {
                        { $joinedline -match "=-" } {
                            $Commands += 'Remove-ItemProperty -Path {0} -Name {1} -Force' -f $key, $Name
                            $Delete = $true
                        }
                        { $joinedline -match '"="' } {
                            $type = "String"
                            $value = $joinedline -replace "`"([^`"=]+)`"="
                        }
                        { $joinedline -match "dword" } {
                            $type = "Dword"
                            $value = $joinedline -replace "`"([^`"=]+)`"=dword:"
                            $value = "0x" + $value
                        }
                        { $joinedline -match "qword" } {
                            $type = "Qword"
                            $value = $joinedline -replace "`"([^`"=]+)`"=qword:"
                            $value = "0x" + $value
                        }
                        { $joinedline -match "hex(\([2,7,b]\))?:" } {
                            $value = ($joinedline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:").split(",")
                            $hextype = ($joinedline | Select-String -pattern "hex(\([2,7,b]\))?").matches.value
                            switch ($hextype) {
                                { $hextype -match 'hex(\([2,7])\)' } {
                                    $ValueEx = '$value = for ($i = 0; $i -lt $value.count; $i += 2) {if ($value[$i] -ne "00") {[string][char][int]("0x" + $value[$i])}'
                                    switch ($hextype) {
                                        'hex(2)' { $type = "ExpandString"; Invoke-Expression $($ValueEx + '}') }
                                        'hex(7)' { $type = "MultiString"; Invoke-Expression $($ValueEx + ' else {","}}'); $value = 0..$($value.count - 3) | % { $value[$_] } }
                                    }
                                    $value = $value -join ""
                                    if ($type -eq "ExpandString") { $value = '"' + $value + '"' }
                                    else {$value = foreach ($seg in $value.split(',')) {'"' + $seg + '"'}; $value = $value -join ','}
                                }
                                'hex(b)' {
                                    $type = "Qword"
                                    $value = for ($i = $value.count - 1; $i -ge 0; $i--) { $value[$i] }
                                    $value = '0x' + ($value -join "").trimstart('0')
                                }
                                'hex' {
                                    $type = "Binary"
                                    $value = $value | %{'0x' + $_}
                                    $value = '([byte[]]$(' + $($value -join ",") + '))'
                                }
                            }
                        }
                    }
                    if (!$Delete) {
                        $Commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3} -Force' -f $key, $name, $type, $value
                    }
                }
                elseif ($joinedline -match "@=") {
                    $name = '"(Default)"'; $type = 'string'; $value = $joinedline -replace '@='
                    $commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3}' -f $key, $name, $type, $value
                }

            }

            $Commands | Out-File -LiteralPath $($file.replace('.reg', '_reg.ps1')) -encoding $encoding
        }
        if ($isfolder) {
            $allcommands = (Get-ChildItem -path $LiteralPath -recurse -force -file -filter "*_reg.ps1").fullname | where-object { $_ -notmatch "allcommands_reg" } | foreach-object { get-content $_ }
            $allcommands | Out-File -path "${path}\allcommands_reg.ps1" -encoding $encoding
        }
    }

    end {}
}

