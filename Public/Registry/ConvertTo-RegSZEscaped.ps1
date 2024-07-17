using namespace System.Text.RegularExpressions
function ConvertTo-RegSZEscaped {
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]] $String,
        [Switch] $InsertDefault,
        [String] $InsertName
    )

    process {
        if($InsertDefault -and (-not[String]::IsNullOrEmpty($InsertName))){
            throw "You cannot use -InsertDefault and -InsertName together."
        }

        foreach ($Str in $String) {
            $Str = $Str -replace '\\','\\'
            $Str = $Str -replace '"','\"'
            $Str = "`"$Str`""
            if($InsertDefault){ $Str = "@=$Str" }
            if($InsertName){ $Str = "`"$InsertName`"=$Str" }
            $Str
        }
    }
}