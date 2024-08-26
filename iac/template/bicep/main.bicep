targetScope = 'subscription'

param project string
param environment string
param location string

module namingConvention_mod '../../../azNamingConvention_sub.json' = {
  name: '${project}-nc'
  params: {
    values: {
      ENVIRONMENT: environment
      ORGANIZATION: null
      PROJECT: project
      REGION: location
    }
    graph: {
      resourceGroup: {
        formatString: 'resourceGroup'
      }
      managedIdentity: {
        formatString: 'managedIdentity'
      }
    }
    userConfig: sys.loadJsonContent('../arm/namingConvention.json')
  }
}

module resourceGroup_mod './resourceGroup.bicep' = {
  name: '${project}-rg'
  params: {
    project: project
    name: namingConvention_mod.outputs.nameGraph
    location: location
  }
}
