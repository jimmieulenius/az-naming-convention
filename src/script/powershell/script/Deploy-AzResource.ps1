# az account set -s 'Stage-DRFIT-VCDM'

"`nResource group" | Out-Default

$resourceGroupName = 'test-dra-ju-rg-01'

$output = az group create `
    --name $resourceGroupName `
    --location 'west europe' `
    --tags `
        environment='test' `
        project='ju'

$output | Out-Default

$output = az deployment group create `
    --name "main" `
    --resource-group $resourceGroupName `
    --template-file 'C:\Users\SuperUser\Source\Repos\personal\az-naming-convention\src\template\bicep\main.bicep'

$outputObject = $output `
| ConvertFrom-Json `
    -AsHashtable

# $outputObject.properties.outputs.deploymentName.value | Out-Default
# $outputObject.properties.outputs.resourceGroupName.value | Out-Default
# $outputObject.properties.outputs.storageAccountName.value | Out-Default
# $outputObject.properties.outputs.subnetName.value | Out-Default
# $outputObject.properties.outputs.suffixName.value | Out-Default

# $outputObject.properties.outputs.config.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default

# $outputObject.properties.outputs.formatNameOutput.value `
# | Out-Default

# $outputObject.properties.outputs.resourceName.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default

# $outputObject.properties.outputs.nameGraphVar.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default

# $outputObject.properties.outputs.nameGraphVar.value.items `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default

$outputObject.properties.outputs.nameGraphMod.value `
| ConvertTo-Json `
    -Depth 100 `
| Out-Default

# $outputObject.properties.outputs.flattenObject.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default

# $outputObject.properties.outputs.resolveRef.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default
# $outputObject.properties.outputs.resolveConfig.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default

# $outputObject.properties.outputs.resourceName.value `
# | Out-Default

# $outputObject.properties.outputs.greeting2.value `
# | ConvertTo-Json `
#     -Depth 100 `
# | Out-Default