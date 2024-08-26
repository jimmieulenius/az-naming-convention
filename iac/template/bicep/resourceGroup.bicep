targetScope = 'subscription'

param project string
param name object
param location string

resource resourceGroup_res 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: name.resourceGroup
  location: location
}

module resource_mod './resource.bicep' = {
  name: '${project}-rsc'
  scope: az.resourceGroup(name.resourceGroup)
  params: {
    name: name
    location: location
    resource: [
      'iac'
    ]
  }
}
