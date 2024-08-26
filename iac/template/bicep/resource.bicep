param name object
param location string
@allowed([
  'iac'
])
param resource string[]

var isResorce = {
  iac: sys.contains(resource, 'iac')
}

resource managedIdentity_res 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (isResorce.iac) {
  name: name.managedIdentity
  location: location
}

// resource resourceGroupRoleAssignment_res 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   scope: az.resourceGroup()
//   name: guid(az.resourceId(resourceType, nameSegments[0]), principalId, roleDefinitionItem.roleDefinitionId)
//   properties: roleDefinitionItem
// }
