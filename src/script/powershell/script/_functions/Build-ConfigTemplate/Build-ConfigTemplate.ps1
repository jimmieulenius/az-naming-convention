param (
    [Parameter(Mandatory = $true)]
    [String[]]
    $Placeholder,

    [Parameter(Mandatory = $true)]
    [String]
    $Destination
)

function Get-PlaceholderOutputValue {
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Name
    )

    return "union(if(contains(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')), 'placeholders'), if(contains(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')).placeholders, '$Name'), if(contains(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')).placeholders.$Name, '`$field'), if(contains(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')).placeholders.$Name.`$field, 'setAction'), if(equals(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')).placeholders.$Name.`$field.setAction, 'replace'), createObject(), reference(variables('placeholdersName')).outputs.$Name.value), reference(variables('placeholdersName')).outputs.$Name.value), reference(variables('placeholdersName')).outputs.$Name.value), reference(variables('placeholdersName')).outputs.$Name.value), reference(variables('placeholdersName')).outputs.$Name.value), if(contains(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')), 'placeholders'), union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')).placeholders, createObject()))"
}

New-Item `
    -Path $Destination `
    -ItemType 'Directory' `
    -ErrorAction 'SilentlyContinue'
| Out-Null

$result = Get-Content `
    -Path "$PSScriptRoot/config.jsontemplate" `
    -Raw `
| ConvertFrom-Json `
    -AsHashtable

if ($Placeholder) {
    $result.outputs.config.value.placeholders = "[union($(
        (
        $Placeholder `
        | ForEach-Object {
            Get-PlaceholderOutputValue `
                -Name (
                    Split-Path `
                        -Path $_ `
                        -LeafBase
                )
        }
    ) -join ','
    ), if(contains(union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')), 'placeholders'), union(if(not(equals(parameters('userConfigTemplateUri'), '')), reference(variables('userConfigName')).outputs.userConfig.value, createObject()), parameters('userConfig')).placeholders, createObject()))]"
}

New-Item `
    -Path "$Destination/config.json" `
    -ItemType 'File' `
    -Value (
        $result
        | ConvertTo-Json `
            -Depth 100
    ) `
    -Force
| Out-Null