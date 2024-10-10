function Get-NumberOfProcessorCoresAndThreads {
    [CmdletBinding()]
    param()

    $LogicalProcessors = [System.Environment]::ProcessorCount
    $PhysicalCores = ((wmic cpu get NumberOfCores | Select-String -Pattern '^[0-9]').Matches.Value) -as [Int32]

    [PSCustomObject]@{
        PhysicalCores = $PhysicalCores
        LogicalProcessors = $LogicalProcessors
    }
}