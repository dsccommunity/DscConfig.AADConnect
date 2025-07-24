# AADSyncRules Composite Resource

## Description

The AADSyncRules composite resource processes arrays of Azure AD Connect sync rule configurations and generates individual `AADSyncRule` DSC resource instances. This resource is designed for bulk processing of sync rule configurations from data sources like YAML files or configuration management systems.

## Parameters

### Items

- **Type**: `hashtable[]`
- **Required**: Yes
- **Description**: Array of hashtables representing sync rule configurations

Each hashtable in the array must contain the parameters required by the underlying `AADSyncRule` resource from the AADConnectDsc module.

## Behavior

### Default Value Application

- If an item does not contain an `Ensure` property, it defaults to `'Present'`
- If an `AttributeFlowMapping` contains a null `Expression` property, it is set to an empty string

### Execution Name Generation

The composite resource generates unique execution names for each sync rule using the pattern:

```
{ConnectorName}__{RuleName}
```

Special characters are replaced with underscores using the regex pattern: `[\s(){}/\\:-]`

### Resource Delegation

Each item in the array is passed to an individual `AADSyncRule` resource instance using the `Get-DscSplattedResource` utility function.

## Examples

### Example 1: Basic Sync Rules Array

```powershell
Configuration BasicSyncRules {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        $syncRuleData = @(
            @{
                Name = 'HR - Inbound - User - Employee'
                ConnectorName = 'hr.contoso.com'
                Direction = 'Inbound'
                TargetObjectType = 'person'
                SourceObjectType = 'user'
                LinkType = 'Provision'
                Precedence = 10
                ScopeFilter = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute = 'employeeType'
                                ComparisonOperator = 'EQUAL'
                                ComparisonValue = 'Employee'
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source = 'givenName'
                        Destination = 'firstName'
                        FlowType = 'Direct'
                    },
                    @{
                        Source = 'sn'
                        Destination = 'lastName'
                        FlowType = 'Direct'
                    }
                )
            },
            @{
                Name = 'Finance - Inbound - User - Financial'
                ConnectorName = 'finance.contoso.com'
                Direction = 'Inbound'
                TargetObjectType = 'person'
                SourceObjectType = 'user'
                LinkType = 'Provision'
                Precedence = 15
                ScopeFilter = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute = 'department'
                                ComparisonOperator = 'EQUAL'
                                ComparisonValue = 'Finance'
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source = 'mail'
                        Destination = 'userPrincipalName'
                        FlowType = 'Direct'
                    }
                )
            }
        )
        
        AADSyncRules 'CompanySyncRules' {
            Items = $syncRuleData
        }
    }
}
```

### Example 2: Configuration Management Integration

This example shows how to use AADSyncRules with configuration management systems like Datum:

```yaml
# In configuration data file (YAML)
AADSyncRules:
  Items:
    - Name: 'Custom - Inbound - User - Manager'
      ConnectorName: 'ad.contoso.com'
      Direction: 'Inbound'
      TargetObjectType: 'person'
      SourceObjectType: 'user'
      LinkType: 'Provision'
      Precedence: 20
      Disabled: false
      ScopeFilter:
        - ScopeConditionList:
            - Attribute: 'manager'
              ComparisonOperator: 'ISNOTNULL'
              ComparisonValue: ''
      AttributeFlowMappings:
        - Source: 'manager'
          Destination: 'manager'
          FlowType: 'Direct'
        - Source: 'extensionAttribute1'
          Destination: 'employeeID'
          FlowType: 'Direct'
    
    - Name: 'Custom - Outbound - Contact - External'
      ConnectorName: 'ad.contoso.com'
      Direction: 'Outbound'
      TargetObjectType: 'contact'
      SourceObjectType: 'contact'
      LinkType: 'Provision'
      Precedence: 25
      AttributeFlowMappings:
        - Source: 'displayName'
          Destination: 'displayName'
          FlowType: 'Direct'
```

```powershell
# In DSC configuration
Configuration ManagementSystemExample {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node $AllNodes.NodeName {
        AADSyncRules 'ConfigMgmtSyncRules' {
            Items = $ConfigurationData.AADSyncRules.Items
        }
    }
}
```

### Example 3: Advanced Attribute Flow Expressions

```powershell
Configuration AdvancedSyncRules {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        $advancedRules = @(
            @{
                Name = 'Advanced - Inbound - User - Transform'
                ConnectorName = 'contoso.com'
                Direction = 'Inbound'
                TargetObjectType = 'person'
                SourceObjectType = 'user'
                LinkType = 'Provision'
                Precedence = 30
                AttributeFlowMappings = @(
                    @{
                        Source = 'givenName'
                        Destination = 'firstName'
                        FlowType = 'Expression'
                        Expression = 'Trim([givenName])'
                    },
                    @{
                        Source = 'sn'
                        Destination = 'lastName'
                        FlowType = 'Expression'
                        Expression = 'UCase(Left([sn],1))+LCase(Mid([sn],2))'
                    }
                )
            }
        )
        
        AADSyncRules 'AdvancedTransformRules' {
            Items = $advancedRules
        }
    }
}
```

## Error Handling

### Common Issues

1. **Missing Required Properties**: If a required property is missing from an item, the underlying `AADSyncRule` resource will generate an error during compilation.

2. **Execution Name Collisions**: The execution name generation algorithm prevents most collisions, but identical combinations of `ConnectorName` and `Name` will cause conflicts.

3. **Invalid Attribute Flow Expressions**: Malformed expressions in `AttributeFlowMappings` will cause runtime errors during sync rule application.

### Troubleshooting

- **Verify Configuration Data**: Ensure all required properties are present in each array item
- **Check Execution Names**: Review generated execution names in the compiled MOF to identify any conflicts
- **Validate Expressions**: Test attribute flow expressions in the Azure AD Connect Synchronization Rules Editor before deployment

## Related Resources

- [AADSyncRule](https://github.com/dsccommunity/AADConnectDsc/wiki/AADSyncRule): The underlying DSC resource
- [AADConnectDirectoryExtensionAttributes](AADConnectDirectoryExtensionAttributes.md): Companion composite resource for directory extensions
- [Azure AD Connect Sync Rules Documentation](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-change-the-configuration): Microsoft documentation on sync rules

## Notes

- This composite resource runs during DSC configuration compilation, not during execution
- All configuration data must be available at compile time
- The resource delegates actual Azure AD Connect operations to the underlying AADSyncRule resources from AADConnectDsc
- Performance scales with the number of items in the array during compilation
