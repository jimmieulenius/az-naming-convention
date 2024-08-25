param environment string = 'stage'
param project string = 'ju'
param instance int = 1

import {
  formatName
  evaluateName
  nameGraph
  resolveRef
  resolveConfig
  flattenObject
} from './core.bicep'
// import {
//   resourceName
//   deploymentName
// } from './userDefinedAzNamingConvention.bicep'

// var shouldDeploy = false
var userConfig = sys.loadJsonContent('../../config/userDefined.json')

// var formatNameOutput = formatName(
//     // '{PROJECT}{-}{INSTANCE}[{-}{SUFFIX}][{DEPLOYMENT_PHASE}]',
//     'default',
//     {
//       ENVIRONMENT: 'stage'
//       ORGANIZATION: 'draftit'
//       PROJECT: 'my first app'
//       PROJECT_INSTANCE: 2
//       // SUBPROJECT: 'api'
//       INSTANCE: 1
//       RESOURCE_TYPE: 'storage account'
//       REGION: 'west europe'
//       VERSION: '0.0.1'
//       SUFFIX: 2
//       DEPLOYMENT_PHASE: {
//         length: 3
//         seed: 'bbb'
//       }
//       UNIQUE: {
//         length: 6
//         seed: 'AAA'
//       }
//     },
//     null,
//     resolveConfig(config.outputs.config)
//   )
// output formatNameOutput string = formatNameOutput

var nameGraph_var = nameGraph(
  '',
  {
    ENVIRONMENT: 'stage'
    ORGANIZATION: 'draftit'
    PROJECT: 'myFirstApp'
    // SUBPROJECT: 'api'
    INSTANCE: 1
    // RESOURCE_TYPE: 'storageAccount'
    REGION: 'west europe'
    VERSION: '0.0.1'
    SUFFIX: 2
    DEPLOYMENT_PHASE: {
      length: 3
      seed: 'bbb'
    }
    UNIQUE: {}
  },
  {
    a: {
      a1: {
        formatString: null
        values: {
          RESOURCE_TYPE: 'resourceGroup'
        }
      }
      a2: {
        formatString: 'subnet'
      }
      aa: {
        aa1: {
          formatString: 'deployment'
        }
        aaa: {
          aaa1: {
            formatString: 'storageAccount'
            values: {
              // RESOURCE_TYPE: 'storageAccount'
            }
          }
        }
      }
    }
    b: {
      bb: 'bb'
    }
    c: {
      formatString: '{AAA}[{-}{BBB}]'
      values: {
        AAA: 'aaa'
        BBB: 'bbb'
        CCC: 'ccc'
      }
    }
    vm: {
      formatString: 'virtualMachine'
      values: {
        // RESOURCE: 'virtualMachine'
        SUBRESOURCE: 'networkInterface'
      }
    }
  },
  'evaluateName',
  null,
  resolveConfig(config.outputs.config)
)
output nameGraphVar object = nameGraph_var

// output resolveRef object = resolveRef(
//   {
//     path: '#/placeholder/REGION'
//   },
//   config.outputs.config
// )
// output resolveConfig object = resolveConfig(
//   config.outputs.config
// )

// module namingConvention_mod '../../../azNamingConvention_rg.json' = {
//   name: 'nc'
//   params: {
//     // value: {
//     //   ENVIRONMENT: environment
//     //   ORGANIZATION: null
//     //   PROJECT: project
//     //   SUBPROJECT: null
//     //   REGION: az.resourceGroup().location
//     //   INSTANCE: instance
//     //   UNIQUE: null
//     // }
//     values: {
//       ENVIRONMENT: 'stage'
//       ORGANIZATION: null
//       PROJECT: 'myFirstApp'
//       // SUBPROJECT: 'api'
//       // PROJECT_INSTANCE: 1
//       REGION: 'west europe'
//       // RESOURCE_INSTANCE: 1
//       VERSION: '0.0.1'
//       SUFFIX: 2
//       DEPLOYMENT_PHASE: {
//         length: 3
//         seed: 'bbb'
//       }
//       UNIQUE: {}
//     }
//     graph: {
//       '${project}': {
//         storage: {
//           account: {
//             formatString: 'storageAccount'
//             values: {
//               SUBPROJECT: 'api'
//             }
//           }
//         }
//         vm: {
//           main: {
//             formatString: 'virtualMachine'
//             values: {
//               RESOURCE_INSTANCE: 1
//             }
//           }
//           nic: {
//             formatString: 'virtualMachine'
//             values: {
//               RESOURCE_INSTANCE: 1
//               SUBRESOURCE: 'networkInterface'
//             }
//           }
//         }
//       }
//       // resourceGroup: {
//       //   resourceType: 'resourceGroup'
//       // }
//       // deployment: {
//       //   format: 'deployment'
//       //   value: {
//       //     PROJECT: 'myFirstApp'
//       //     VERSION: '0.0.1'
//       //     DEPLOYMENT_PHASE: {}
//       //     SUFFIX: 'awa'
//       //   }
//       // }
//       // subnet: {
//       //   // format: '{ENVIRONMENT}-{PROJECT}-{INSTANCE}[{-}{UNIQUE}]'
//       //   format: 'subnet'
//       //   // format: '{ENVIRONMENT}-{WORKLOAD}-{INSTANCE}[{-}{UNIQUE}]'
//       //   value: {
//       //     ENVIRONMENT: 'test'
//       //     UNIQUE: {}
//       //   }
//       // }
//     }
//     function: 'evaluateName'
//     userConfig: userConfig
//     // environmentTemplateUri: 'https://raw.githubusercontent.com/jimmieulenius/az-config/main/template/arm/naming-convention/environment.json'
//     // formatTemplateUri: 'https://raw.githubusercontent.com/jimmieulenius/az-config/main/template/arm/naming-convention/format.json'
//     // userConfigTemplateUri: 'https://raw.githubusercontent.com/jimmieulenius/az-config/main/template/arm/naming-convention/userConfig.json'
//   }
// }
// output nameGraphMod object = namingConvention_mod.outputs.nameGraph

module config '../arm/config.json' = {
  name: 'nc-config'
  params: {
    formatTemplateUri: 'https://raw.githubusercontent.com/jimmieulenius/az-naming-convention/main/src/template/arm/config/format.json'
    placeholdersTemplateUri: 'https://raw.githubusercontent.com/jimmieulenius/az-naming-convention/main/src/template/arm/config/placeholders.json'
    userConfigTemplateUri: 'https://raw.githubusercontent.com/jimmieulenius/az-config/main/naming-convention/template/arm/userConfig.json'
    userConfig: {
      placeholders: {
        REGION: {
          source: {
            northeurope: {
              value: 'ne'
            }
          }
        }
      }
    }
  }
}
// output config object = resolveConfig(config.outputs.config)
output config object = config.outputs.config

// output flattenObject array = flattenObject({
//   a: {
//     aa: 'aa'
//     bb: {
//       formatInfo: {}
//       isValid: true
//       result: 'hjsh'
//     }
//   }
// })

// output resourceName string = resourceNameObject2

// resource storageAccount_res 'Microsoft.Storage/storageAccounts@2023-04-01' = if (shouldDeploy) {
//   name: azResourceName('stage', null, 'storageAccount', 'ju', null, 1, null, null)
//   location: 'westeurope'
//   sku: {
//     name: 'Standard_RAGRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     defaultToOAuthAuthentication: false
//     allowCrossTenantReplication: true
//     minimumTlsVersion: 'TLS1_2'
//     allowBlobPublicAccess: false
//     allowSharedKeyAccess: true
//     supportsHttpsTrafficOnly: true
//     encryption: {
//       services: {
//         file: {
//           keyType: 'Account'
//           enabled: true
//         }
//         blob: {
//           keyType: 'Account'
//           enabled: true
//         }
//       }
//       keySource: 'Microsoft.Storage'
//     }
//     accessTier: 'Hot'
//   }
// }

// output deploymentName string = azDeploymentName(
//   'stage',
//   null,
//   'resourceGroup',
//   'ju',
//   null,
//   1,
//   null,
//   '0.0.1',
//   {},
//   null,
//   {}
// )
// output resourceGroupName string = azResourceName(
//   'stage',
//   null,
//   'resourceGroup',
//   'myFirstApp',
//   null,
//   1,
//   'westeurope',
//   null
// )
// output storageAccountName string = azResourceName(
//   'stage',
//   null,
//   'storageAccount',
//   'JU',
//   'api',
//   1,
//   'west europe',
//   null
// )
// output subnetName string = azFormatResourceName(
//   'storageAccount',
//   {
//     ENVIRONMENT: 'stage'
//     ORGANIZATION: null
//     PROJECT: null
//     SUBPROJECT: 'api'
//     INSTANCE: 1
//     RESOURCE_TYPE: 'storageAccount'
//     REGION: null
//     VERSION: '0.0.1'
//     UNIQUE: null
//   },
//   sys.loadJsonContent('../../config/namingConvention/userDefined.json')
// )
// output suffixName string = azFormatResourceName(
//   '{NAME}[{-}{SUFFIX}]',
//   {
//     NAME: 'aaa'
//     SUFFIX: ''
//   },
//   sys.loadJsonContent('../../config/namingConvention/userDefined.json')
// )
