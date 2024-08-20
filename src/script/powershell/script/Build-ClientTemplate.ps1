& "$PSScriptRoot/_functions/Import-FunctionScript.ps1" `
    -Name @(
        'Build-ClientTemplate/'
    ) `
    -AllowClobber

Build-ClientTemplate `
    -Destination "$PSScriptRoot/../../../template/arm"