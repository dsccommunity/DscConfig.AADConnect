# AADConnectDirectoryExtensionAttributes Composite Resource

## Description

The AADConnectDirectoryExtensionAttributes composite resource processes arrays of directory extension attribute configurations and generates individual `AADConnectDirectoryExtensionAttribute` DSC resource instances. This resource enables bulk management of custom directory schema extensions for Azure AD Connect.

## Parameters

### Items

- **Type**: `hashtable[]`
- **Required**: Yes
- **Description**: Array of hashtables representing directory extension configurations

Each hashtable in the array must contain the parameters required by the underlying `AADConnectDirectoryExtensionAttribute` resource from the AADConnectDsc module.

## Behavior

### Default Value Application

- If an item does not contain an `Ensure` property, it defaults to `'Present'`

### Execution Name Generation

The composite resource generates unique execution names for each directory extension using the pattern:

```
{AttributeName}__{ObjectClass}
```

Special characters are replaced with underscores using the regex pattern: `[\s(){}/\\:-]`

### Resource Delegation

Each item in the array is passed to an individual `AADConnectDirectoryExtensionAttribute` resource instance using the `Get-DscSplattedResource` utility function.

## Examples

### Example 1: Basic Directory Extensions

```powershell
Configuration BasicDirectoryExtensions {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        $extensionData = @(
            @{
                Name = 'employeeID'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            },
            @{
                Name = 'costCenter'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            },
            @{
                Name = 'departmentCode'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            },
            @{
                Name = 'managerEmail'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            }
        )
        
        AADConnectDirectoryExtensionAttributes 'CompanyExtensions' {
            Items = $extensionData
        }
    }
}
```

### Example 2: Multiple Object Classes

```powershell
Configuration MultiObjectExtensions {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        $multiExtensions = @(
            # User extensions
            @{
                Name = 'badge'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            },
            @{
                Name = 'isContractor'
                AssignedObjectClass = 'user'
                Type = 'Boolean'
                IsEnabled = $true
            },
            # Group extensions
            @{
                Name = 'projectCode'
                AssignedObjectClass = 'group'
                Type = 'String'
                IsEnabled = $true
            },
            @{
                Name = 'budgetCenter'
                AssignedObjectClass = 'group'
                Type = 'String'
                IsEnabled = $true
            }
        )
        
        AADConnectDirectoryExtensionAttributes 'MultiObjectExtensions' {
            Items = $multiExtensions
        }
    }
}
```

### Example 3: Configuration Management Integration

This example shows integration with configuration management systems:

```yaml
# In configuration data file (YAML)
AADConnectDirectoryExtensionAttributes:
  Items:
    - Name: 'hireDate'
      AssignedObjectClass: 'user'
      Type: 'DateTime'
      IsEnabled: true
    
    - Name: 'securityClearance'
      AssignedObjectClass: 'user'
      Type: 'String'
      IsEnabled: true
    
    - Name: 'locationCode'
      AssignedObjectClass: 'user'
      Type: 'String'
      IsEnabled: true
    
    - Name: 'teamLead'
      AssignedObjectClass: 'group'
      Type: 'String'
      IsEnabled: true
```

```powershell
# In DSC configuration
Configuration DataDrivenExtensions {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node $AllNodes.NodeName {
        AADConnectDirectoryExtensionAttributes 'ConfigMgmtExtensions' {
            Items = $ConfigurationData.AADConnectDirectoryExtensionAttributes.Items
        }
    }
}
```

### Example 4: Different Data Types

```powershell
Configuration TypedExtensions {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        $typedExtensions = @(
            @{
                Name = 'employeeStartDate'
                AssignedObjectClass = 'user'
                Type = 'DateTime'
                IsEnabled = $true
            },
            @{
                Name = 'isFullTime'
                AssignedObjectClass = 'user'
                Type = 'Boolean'
                IsEnabled = $true
            },
            @{
                Name = 'salaryGrade'
                AssignedObjectClass = 'user'
                Type = 'Integer'
                IsEnabled = $true
            },
            @{
                Name = 'personalNote'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $false  # Disabled for privacy
            }
        )
        
        AADConnectDirectoryExtensionAttributes 'TypedExtensions' {
            Items = $typedExtensions
        }
    }
}
```

### Example 5: Conditional Extensions

```powershell
Configuration ConditionalExtensions {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        # Extensions can be conditionally included based on environment
        $extensions = @(
            @{
                Name = 'environment'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            }
        )
        
        # Add development-specific extensions
        if ($Node.Environment -eq 'Development') {
            $extensions += @{
                Name = 'debugLevel'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            }
        }
        
        # Add production-specific extensions
        if ($Node.Environment -eq 'Production') {
            $extensions += @{
                Name = 'auditTrail'
                AssignedObjectClass = 'user'
                Type = 'String'
                IsEnabled = $true
            }
        }
        
        AADConnectDirectoryExtensionAttributes 'ConditionalExtensions' {
            Items = $extensions
        }
    }
}
```

## Error Handling

### Common Issues

1. **Missing Required Properties**: Required properties like `Name`, `AssignedObjectClass`, and `Type` must be present in each item.

2. **Invalid Data Types**: The `Type` property must be a valid Azure AD directory extension type (String, Boolean, Integer, DateTime).

3. **Execution Name Collisions**: Identical combinations of `Name` and `AssignedObjectClass` will cause execution name conflicts.

4. **Schema Conflicts**: Attempting to create extensions that conflict with existing Azure AD schema will cause runtime errors.

### Troubleshooting

- **Verify Required Properties**: Ensure all mandatory properties are present in each array item
- **Check Data Types**: Validate that `Type` values are supported Azure AD extension types
- **Review Execution Names**: Check compiled MOF for execution name conflicts
- **Test Schema Changes**: Validate extensions in a development environment before production deployment

## Supported Data Types

Azure AD Connect directory extensions support the following data types:

- **String**: Text values (most common)
- **Boolean**: True/false values
- **Integer**: Numeric values
- **DateTime**: Date and time values

## Best Practices

### Naming Conventions

- Use descriptive names that clearly indicate the attribute purpose
- Follow your organization's naming standards
- Consider prefixing with company abbreviation (e.g., 'contoso_employeeID')

### Type Selection

- Use **String** for most text-based attributes
- Use **Boolean** for yes/no or enabled/disabled attributes
- Use **Integer** for numeric identifiers or counts
- Use **DateTime** for date-based attributes

### Performance Considerations

- Limit the number of extensions to avoid performance impact
- Consider the sync frequency when adding new extensions
- Test in development environments before production deployment

## Related Resources

- [AADConnectDirectoryExtensionAttribute](https://github.com/dsccommunity/AADConnectDsc/wiki/AADConnectDirectoryExtensionAttribute): The underlying DSC resource
- [AADSyncRules](AADSyncRules.md): Companion composite resource for sync rules
- [Azure AD Schema Extensions Documentation](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-feature-directory-extensions): Microsoft documentation

## Notes

- This composite resource runs during DSC configuration compilation
- All configuration data must be available at compile time
- Directory extensions require Azure AD Connect service restart to take effect
- Extensions are tenant-wide and affect all connected directories
- Performance scales with the number of items during compilation
- Changes to directory extensions may require full synchronization cycles
