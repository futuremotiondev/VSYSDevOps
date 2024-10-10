using module "..\..\Completions\Completers.psm1"
using namespace Spectre.Console
using namespace System.Collections.Generic
using namespace System.Text.RegularExpressions
<#
.SYNOPSIS
    A light weight but feature rich logging utility with custom formatting and the ability to save results to a log file.
    Also provides detailed information for 'ERROR' logs including the script line number, function name, and the exact code that failed.

.DESCRIPTION
    The New-Log function is a versatile logging utility designed to provide detailed logs with customizable formatting for PowerShell scripts.
    It supports logging messages of different severity levels, including ERROR, WARNING, INFO, SUCCESS, and DEBUG.
    The function also handles different PowerShell versions, including PowerShell Core (6 and above), and adjusts the console output for color-coded messages based on the severity level.
    Additionally, it provides detailed information for ERROR logs, including the script line number, function name, and the exact code that failed, enhancing the debugging process.

.PARAMETER Message
    The log message, which can be a string, hashtable, or PSCustomObject.

.PARAMETER Level
    Specifies the severity level of the log message, defaulting to INFO.

.PARAMETER IncludeCallerInfo
    Includes information about the calling function in the log message.
    If specified, the log will display the function name and other details related to the caller.
    This is especially useful when tracing logs in larger scripts or modules.

.PARAMETER NoConsole
    Suppresses console output if specified, useful for silent logging.

.PARAMETER PassThru
    Returns the formatted log message as a string instead of writing it to the console or file.

.PARAMETER AsObject
    Returns the log entry as a PSCustomObject, which can be useful for further processing or outputting structured data.

.PARAMETER OverwriteLogFile
    Overwrites the existing log file with the new log entry if specified, otherwise appends to the log file.

.PARAMETER LogFilePath
    Specifies the path to the log file where the message should be written. If the directory does not exist, it is created automatically.

.EXAMPLE
    Log an informational message to the console
    New-Log -Message "The process completed successfully." -Level "INFO"
.EXAMPLE
    try { Get-ChildItem -Path C:\ttmm -ErrorAction Stop }
    catch { New-Log -Message "A critical error occurred in the script." -Level "ERROR" -LogFilePath "C:\Logs\error.log" }
.EXAMPLE
    Log a debug message without console output but returning the log as a string
    $logEntry = New-Log -Message "Debugging the script." -Level "DEBUG" -NoConsole -PassThru
.EXAMPLE
    Log a success message and return it as a PSCustomObject for further processing
    $logObject = New-Log -Message "Operation completed successfully." -Level "SUCCESS" -AsObject
.EXAMPLE
    Overwrite the existing log file with a warning message
    New-Log -Message "This will overwrite the log file." -Level "WARNING" -LogFilePath "C:\Logs\warning.log" -OverwriteLogFile
.EXAMPLE
    Log a message with a PSCustomObject and output it both to the console and as a PSCustomObject
    $customMessage = [PSCustomObject]@{
        UserName = "Admin"
        Action   = "Login"
        Status   = "Success"
    }
    $returnedObject = $customMessage | New-Log -Level "INFO" -PassThru -AsObject

.NOTES
    Original Author: Harze2k on Github
    Updated By: Futuremotion
    Date: 09-11-2024
#>
function New-Log {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,Position=0)] $Message,
        [ValidateSet("ERROR", "WARNING", "INFO", "SUCCESS", "DEBUG", IgnoreCase=$true)]
        [string] $Level = "INFO",
        [switch] $IncludeCallerInfo = $false,
        [switch] $NoConsole,
        [switch] $PassThru,
        [switch] $AsObject,
        [switch] $OverwriteLogFile,
        [string] $LogFilePath,
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $TimestampColor="#dde1e6",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $DefaultTextColor="#a0a4ab",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $DebugColor="#dfe4eb",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $ErrorColor="#f57a88",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $InfoColor="#c8d1df",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $SuccessColor="#8cddb9",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $WarningColor="#eab077",
        [ArgumentCompletionsSpectreColorsVSYS()]
        [String] $InternalErrorColor="#f0a2a2"
    )

    begin {
        $levelColors = @{
            "ERROR"   = $ErrorColor
            "WARNING" = $WarningColor
            "SUCCESS" = $SuccessColor
            "DEBUG"   = $DebugColor
            "INFO"    = $InfoColor
        }
        try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 }
        catch { Write-SpectreHost "[#DCDFE5]Notice:[/] [#ABB1BC]Unable to set console encoding to [#FFFFFF]UTF8[/][/]" }
    }

    process {

        if ($null -eq $Message -and $Level -ne "ERROR") { return }

        $sEscapeL = Get-SpectreEscapedText -Text "["
        $sEscapeR = Get-SpectreEscapedText -Text "]"

        try {
            @('exceptionMessage', 'failedCode', 'scriptLines', 'lineInfo') |
                ForEach-Object { Set-Variable -Name $_ -Value $null }

            if ($Message -is [hashtable]) { $Message = [pscustomobject]$Message }

            # Check for unsupported message types
            $validTypes = [HashSet[string]]::new()
            $validTypes.Add("PSCustomObject") | Out-Null
            $validTypes.Add("Hashtable") | Out-Null
            $validTypes.Add("String") | Out-Null
            $validTypes.Add("Software") | Out-Null

            if ($Message -and -not $validTypes.Contains($Message.GetType().Name)) {
                $UnsupportedMsg = "Must be PSCustomObject, Hashtable, String, or Software"
                New-Log "Unsupported message type: $($Message.GetType().Name). $UnsupportedMsg" -ForegroundColor Red
                return
            }

            # Initialize variables
            $logSentToConsole = $false
            $logMessage = ''
            $logMessageConsole = ''
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            $callerInfo = (Get-PSCallStack)[1]
            $originalMessage = $Message
            $levelColor = $levelColors[$Level]

            $headerPrefix = "$sEscapeL[$TimestampColor]$timestamp[/]$sEscapeR $sEscapeL[$levelColor]$Level[/]$sEscapeR"
            $headerPrefixFile = "[$timestamp] [$Level]"

            # Format message if not a string
            if ($Message -isnot [string]) { $Message = ($Message | Format-List | Out-String).Trim() }

            # Include caller info if necessary
            $includeFunctionInfo = $callerInfo.FunctionName -ne '<ScriptBlock>' -and ($IncludeCallerInfo.IsPresent -or $Level -eq "ERROR")
            $functionInfo = if ($includeFunctionInfo) { "$sEscapeL[$TimestampColor]Function:[/] $($callerInfo.FunctionName)$sEscapeR" } else { "" }
            $functionInfoFile = if ($includeFunctionInfo) { "[Function: $($callerInfo.FunctionName)]" } else { "" }

            $messageLines = if ($Message) {
                $Message -split "`n" | ForEach-Object { "$headerPrefix [$DefaultTextColor]$_[/]" }
            } else {
                "$headerPrefix${_}"
            }

            $messageLinesFile = if ($Message) {
                $Message -split "`n" | ForEach-Object { "$headerPrefixFile $_" }
            } else {
                "$headerPrefixFile${_}"
            }

            $logMessage += ($messageLines -join "`n") + $functionInfo
            $logMessageFile += ($messageLinesFile -join "`n") + $functionInfoFile

            # Handle error logging
            if ($Level -eq "ERROR" -and $Error[0]) {
                $errorRecord = $Error[0]
                $invocationInfo = $errorRecord.InvocationInfo

                try {
                    $scriptPath = $errorRecord.InvocationInfo.PSCommandPath ?? $errorRecord.InvocationInfo.ScriptName
                    if ($scriptPath -and (Test-Path -Path $scriptPath)) {
                        $scriptLines = Get-Content -Path $scriptPath -ErrorAction Stop
                    }
                } catch {
                    Write-SpectreHost "$sEscapeL[$TimestampColor]$timestamp[/]$sEscapeR$sEscapeL[$InternalErrorColor]INTERNAL_ERROR[/]$sEscapeR An error occurred in New-Log function."
                    Write-SpectreHost "[$InternalErrorColor]$($_.Exception.Message)[/]"
                }

                $functionName = $callerInfo.Command
                $failedCode = $invocationInfo.Line?.Trim()
                [int]$errorLine = $errorRecord.InvocationInfo.ScriptLineNumber ?? $invocationInfo.ScriptLineNumber

                if ($scriptLines) {
                    [int]$functionStartLine = ($scriptLines | Select-String -Pattern "function\s+$functionName" | Select-Object -First 1).LineNumber
                    $lineNumberInFunction = $errorLine - $functionStartLine
                    $lineInfo = "($lineNumberInFunction,$errorLine) (Function,Script)"
                    if ($callerInfo.FunctionName -eq '<ScriptBlock>') {
                        $lineInfo = "$errorLine (Script)"
                    }
                } else {
                    $lineNumberInFunction = $errorLine - ([int]$callerInfo.ScriptLineNumber - [int]$invocationInfo.OffsetInLine) - 1
                    $lineInfo = "($lineNumberInFunction,$errorLine) (Function,Script)"
                    if ($callerInfo.FunctionName -eq '<ScriptBlock>') {
                        $lineInfo = "$errorLine (Script)"
                    }
                }

                $exceptionMessage = $errorRecord.Exception.Message
                $logMessage += "$sEscapeL[$InternalErrorColor]CodeRow:[/] $lineInfo$sEscapeR"
                $logMessage += "$sEscapeL[$InternalErrorColor]FailedCode:[/] $failedCode$sEscapeR"
                $logMessage += "$sEscapeL[$InternalErrorColor]ExceptionMessage:[/] [$ErrorColor]$exceptionMessage[/]$sEscapeR"
                $logMessageFile += "CodeRow: $lineInfo"
                $logMessageFile += "FailedCode: $failedCode"
                $logMessageFile += "ExceptionMessage: $exceptionMessage"
            }

            function Write-MessageToConsole {
                if ($LogSentToConsole -eq $true) { return }
                if (-not($NoConsole.IsPresent)) { Write-SpectreHost $logMessage }
                return $true
            }

            # Log to console if conditions are met
            if (!($NoConsole.IsPresent) -and !($PassThru.IsPresent) -and !($AsObject.IsPresent) -and !$LogFilePath) {
                $LogSentToConsole = Write-MessageToConsole
            }

            # Handle log file writing
            if ($LogFilePath) {
                $LogSentToConsole = Write-MessageToConsole
                $parentDir = Split-Path -Path $LogFilePath -Parent
                if (-not (Test-Path -Path $parentDir)) {
                    New-Item -Path $parentDir -ItemType Directory -Force
                }
                if ($OverwriteLogFile.IsPresent) {
                    Remove-Item -Path $LogFilePath -Force -ErrorAction SilentlyContinue
                    Set-Content -Value $logMessageFile -Path $LogFilePath -Force -Encoding utf8
                } else {
                    Add-Content -Value $logMessageFile -Path $LogFilePath -Encoding utf8
                }
            }

            $object = [PSCustomObject]@{
                Timestamp      = $timestamp
                Level          = $Level
                Message        = if ($originalMessage -is [string]) { $Message } else { $Message | Out-String }
                Exception      = if (-not [string]::IsNullOrEmpty($exceptionMessage)) { $exceptionMessage } else { $null }
                CallerFunction = if ($callerInfo.FunctionName -eq '<ScriptBlock>') { $null } else { $callerInfo.FunctionName }
                CodeRow        = if (-not [string]::IsNullOrEmpty($lineInfo)) { $lineInfo } else { $null }
                FailedCode     = if (-not [string]::IsNullOrEmpty($FailedCode)) { $FailedCode } else { $null }
            }

            if ($PassThru.IsPresent) {
                $LogSentToConsole = Write-MessageToConsole
                return if ($AsObject.IsPresent) { $object } else { $logMessage }
            } elseif (!$NoConsole.IsPresent -and $AsObject.IsPresent) {
                $object | Out-Host
            }
        }
        catch {
            Write-SpectreHost "$sEscapeL[$TimestampColor]$timestamp[/]$sEscapeR$sEscapeL[$ErrorColor]ERROR[/]$sEscapeR [$DefaultTextColor]An error occurred in New-Log function.[/] [$ErrorColor]$($_.Exception.Message)[/]"
        }
    }
}