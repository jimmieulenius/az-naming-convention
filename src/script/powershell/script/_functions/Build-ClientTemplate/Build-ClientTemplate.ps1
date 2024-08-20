param (
    [Parameter(Mandatory = $true)]
    [String]
    $Destination,

    [ValidateSet(
        'resourceGroup',
        'subscription'
    )]
    [String]
    $Scope = 'resourceGroup'
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

    switch ($Scope) {
        ('subscription') {
            $InputObject.'$schema' = 'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#'
        }
    }

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

$fileBaseName = 'azNamingConvention'

switch ($Scope) {
    ('subscription') {
        $fileBaseName = "$($fileBaseName)_sub"
    }
    default {
        $fileBaseName = "$($fileBaseName)_rg"
    }
}

New-Item `
    -Path "$Destination/$fileBaseName.json" `
    -ItemType 'File' `
    -Value (
        $result `
        | Edit-Template
    ) `
    -Force
| Out-Null