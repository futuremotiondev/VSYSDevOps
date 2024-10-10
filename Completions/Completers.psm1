using namespace Spectre.Console
using namespace System.Management.Automation

class ArgumentCompletionsSpectreColorsVSYS : ArgumentCompleterAttribute {
    ArgumentCompletionsSpectreColorsVSYS() : base({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $options = [Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
            return $options | Where-Object { $_ -like "$wordToComplete*" }
        }) { }
}
