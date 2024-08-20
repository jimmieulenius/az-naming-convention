param (
    [Parameter(Mandatory = $true)]
    [String[]]
    $ConfigPath,

    [Parameter(Mandatory = $true)]
    [String]
    $Destination
)

New-Item `
    -Path (
        Split-Path `
            -Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination) `
            -Parent
    ) `
    -ItemType 'Directory' `
    -ErrorAction 'SilentlyContinue'
| Out-Null

$result = Get-Content `
    -Path "$PSScriptRoot/config.jsontemplate" `
    -Raw
| ConvertFrom-Json `
    -AsHashtable

$ConfigPath
| ForEach-Object {
    $name = Split-Path `
        -Path $_ `
        -LeafBase
    $result.outputs.$name = @{
        value = (
            Get-Content `
                -Path $_ `
                -Raw
            | ConvertFrom-Json `
                -AsHashtable
        )
        type = 'object'
    }
}

New-Item `
    -Path $Destination `
    -ItemType 'File' `
    -Value (
        $result
        | ConvertTo-Json `
            -Depth 100
    ) `
    -Force
| Out-Null