param (
    [Parameter(Mandatory = $true)]
    [String]
    $TemplatePath,

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

    $template = Get-Content `
        -Path "$PSScriptRoot/core.jsontemplate" `
        -Raw
    | ConvertFrom-Json `
        -AsHashtable

    $InputObject.parameters = $template.parameters
    $InputObject.resources = $template.resources
    $InputObject.outputs = $template.outputs

    $config = Get-Content `
        -Path "$PSScriptRoot/config.json" `
        -Raw `
    | ConvertFrom-Json `
        -AsHashtable

    $InputObject.resources.config.properties.templateLink.uri = $config.configTemplateUri

    $InputObject.Remove('metadata')
    $InputObject.functions[0].members.GetEnumerator() `
    | ForEach-Object {
        $_.Value.Remove('metadata')
    }

    $namespace = 'namingConvention'
    $InputObject.functions[0].namespace = $namespace

    return (
        $InputObject `
        | ConvertTo-Json `
            -Depth 100
    ).Replace('__bicep.', "$namespace.")
}

New-Item `
    -Path $Destination `
    -ItemType 'Directory' `
    -ErrorAction 'SilentlyContinue'
| Out-Null

$result = (
    az bicep build `
        --file $TemplatePath `
        --stdout
)
| ConvertFrom-Json `
    -AsHashtable

# $template = Get-Content `
#     -Path "$PSScriptRoot/core.jsontemplate" `
#     -Raw
# | ConvertFrom-Json `
#     -AsHashtable

# $result.parameters = $template.parameters
# $result.resources = $template.resources
# $result.outputs = $template.outputs

New-Item `
    -Path "$Destination/$(
            Split-Path -Path $TemplatePath -LeafBase
        ).json" `
    -ItemType 'File' `
    -Value (
        $result `
        | Edit-Template
    ) `
    -Force
| Out-Null