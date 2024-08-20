param (
    [Parameter(Mandatory = $true)]
    [String]
    $Destination
)

function Edit-Template {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [Hashtable]
        $InputObject
    )

    $config = Get-Content `
        -Path "$PSScriptRoot/config.json" `
        -Raw `
    | ConvertFrom-Json `
        -AsHashtable

    $InputObject.parameters.coreTemplateUri.defaultValue = $config.coreTemplateUri
    $InputObject.parameters.formatTemplateUri.defaultValue = $config.formatTemplateUri
    $InputObject.parameters.placeholdersTemplateUri.defaultValue = $config.placeholdersTemplateUri

    return (
        $InputObject `
        | ConvertTo-Json `
            -Depth 100
    )
}

New-Item `
    -Path $Destination `
    -ItemType 'Directory' `
    -ErrorAction 'SilentlyContinue'
| Out-Null

$result = Get-Content `
    -Path "$PSScriptRoot/client.jsontemplate" `
    -Raw
| ConvertFrom-Json `
    -AsHashtable

New-Item `
    -Path "$Destination/azNamingConvention.json" `
    -ItemType 'File' `
    -Value (
        $result `
        | Edit-Template
    ) `
    -Force
| Out-Null