& "$PSScriptRoot/_functions/Import-FunctionScript.ps1" `
    -Name @(
        'Build-CoreTemplate/'
    ) `
    -AllowClobber

Build-CoreTemplate `
    -TemplatePath "$PSScriptRoot/../../../template/bicep/core.bicep" `
    -Destination "$PSScriptRoot/../../../template/arm"