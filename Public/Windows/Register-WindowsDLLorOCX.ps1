function Register-WindowsDLLorOCX {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [string]
        $File,

        [Parameter(Mandatory = $false, Position = 1)]
        [switch]
        $Unregister
    )

    if($Unregister){
        $Result = Invoke-VBMessageBox "Are you sure you want to unregister this library? ($File)" -Title "Confirmation" -Icon Question -BoxType YesNoCancel -DefaultButton 3
        if($Result -ne 'Yes') {
            Write-Host "User canceled the process."
            exit
        }
        regsvr32.exe -u $File
    }else{
        $Result = Invoke-VBMessageBox "Are you sure you want to register this library? ($File)" -Title "Confirmation" -Icon Question -BoxType YesNoCancel -DefaultButton 3
        if($Result -ne 'Yes'){
            Write-Host "User canceled the process."
            exit
        }else{
            regsvr32.exe $File
        }
    }
}