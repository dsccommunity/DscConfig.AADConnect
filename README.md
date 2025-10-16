# DscConfig.AADConnect

[![Build Status](https://img.shields.io/badge/build-status-blue.svg)](https://dev.azure.com/dsccommunity/DscConfig.AADConnect) 
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/DscConfig.AADConnect.svg)](https://www.powershellgallery.com/packages/DscConfig.AADConnect/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

DscConfig.AADConnect is a PowerShell DSC composite resource module that provides simplified interfaces for managing Azure AD Connect configurations through configuration data arrays. This module serves as a translation layer between configuration management systems (like Datum and DscWorkshop) and the underlying AADConnectDsc resources.

## Overview

This module provides composite DSC resources that accept arrays of configuration items and automatically generate individual AADConnectDsc resource instances. It simplifies bulk configuration management by:

- **Array Processing**: Processes arrays of hashtables representing sync rules and directory extensions
- **Execution Name Generation**: Automatically creates unique execution names to prevent resource conflicts
- **Default Value Management**: Applies sensible defaults (like `Ensure = 'Present'`) when not specified
- **Configuration Management Integration**: Designed for use with enterprise configuration management frameworks

## Composite Resources

### AADSyncRules

Processes arrays of Azure AD Connect sync rule configurations and generates individual `AADSyncRule` DSC resource instances.

**Key Features:**
- Bulk processing of sync rule configurations
- Automatic execution name generation from connector and rule names
- Expression validation for attribute flow mappings
- Default value application for common scenarios

### AADConnectDirectoryExtensionAttributes

Processes arrays of directory extension attribute configurations and generates individual `AADConnectDirectoryExtensionAttribute` DSC resource instances.

**Key Features:**
- Bulk processing of directory extension configurations
- Execution name generation from attribute name and object class
- Schema validation and type checking
- Integration with Azure AD schema requirements

## Requirements

### System Requirements

- **Windows PowerShell 5.1**: Required for DSC composite resource functionality
- Windows Server 2012 R2 or later
- .NET Framework 4.6 or later

### Dependencies

- **AADConnectDsc**: The underlying DSC resource module for Azure AD Connect management
- **DscResource.Common**: Utilities for DSC resource operations
- **PSDesiredStateConfiguration**: Core DSC framework (included with Windows PowerShell)

## Installation

To install from the PowerShell Gallery:

```powershell
Install-Module -Name DscConfig.AADConnect -Repository PSGallery
```

## Quick Start

### Basic Usage with Configuration Data

Here's a basic example of using DscConfig.AADConnect composite resources with configuration data:

```powershell
Configuration AADConnectConfiguration {
    Import-DscResource -ModuleName DscConfig.AADConnect
    
    Node localhost {
        # Define sync rules as an array
        $syncRules = @(
            @{
                Name = 'Custom User Rule'
                ConnectorName = 'contoso.com'
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
                    }
                )
            }
        )
        
        # Use the composite resource to process the array
        AADSyncRules 'CompanyUserRules' {
            Items = $syncRules
        }
        
        # Define directory extensions as an array
        $directoryExtensions = @(
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
            }
        )
        
        # Use the composite resource to process the array
        AADConnectDirectoryExtensionAttributes 'CompanyExtensions' {
            Items = $directoryExtensions
        }
    }
}
```

### Integration with Configuration Management Systems

DscConfig.AADConnect is designed to work with configuration management frameworks like Datum and DscWorkshop:

```yaml
# In your configuration data (YAML)
AADSyncRules:
  Items:
    - Name: 'HR - Inbound - User - Employee'
      ConnectorName: 'hr.contoso.com'
      Direction: 'Inbound'
      TargetObjectType: 'person'
      SourceObjectType: 'user'
      LinkType: 'Provision'
      Precedence: 15
      # Additional properties...
    
    - Name: 'Finance - Inbound - User - Financial'
      ConnectorName: 'finance.contoso.com'
      Direction: 'Inbound'
      TargetObjectType: 'person'
      SourceObjectType: 'user'
      LinkType: 'Provision'
      Precedence: 20
      # Additional properties...

AADConnectDirectoryExtensionAttributes:
  Items:
    - Name: 'departmentCode'
      AssignedObjectClass: 'user'
      Type: 'String'
      IsEnabled: true
    
    - Name: 'managerEmail'
      AssignedObjectClass: 'user'
      Type: 'String'
      IsEnabled: true
```

## Resource Documentation

For detailed documentation on each composite resource, see:

- **[AADSyncRules](docs/AADSyncRules.md)**: Processes arrays of Azure AD Connect sync rule configurations
- **[AADConnectDirectoryExtensionAttributes](docs/AADConnectDirectoryExtensionAttributes.md)**: Processes arrays of directory extension attribute configurations

### Quick Reference

#### AADSyncRules

**Parameters:**

- **Items** (Mandatory): Array of hashtables representing sync rule configurations
  - Each hashtable must contain the parameters required by the underlying `AADSyncRule` resource
  - The `Ensure` property defaults to 'Present' if not specified
  - Expression properties in AttributeFlowMappings are set to empty string if null

**Execution Name Generation:**
Execution names are generated using the pattern: `{ConnectorName}__{RuleName}` with special characters replaced by underscores.

#### AADConnectDirectoryExtensionAttributes

**Parameters:**

- **Items** (Mandatory): Array of hashtables representing directory extension configurations
  - Each hashtable must contain the parameters required by the underlying `AADConnectDirectoryExtensionAttribute` resource
  - The `Ensure` property defaults to 'Present' if not specified

**Execution Name Generation:**
Execution names are generated using the pattern: `{AttributeName}__{ObjectClass}` with special characters replaced by underscores.

## Examples

For additional examples and advanced usage scenarios, see the [Examples](examples/) directory.

## Contributing

Please check out the DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Change Log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Related Projects

- **[AADConnectDsc](https://github.com/dsccommunity/AADConnectDsc)**: The underlying DSC resource module
- **[AADConnectConfig](https://github.com/raandree/AADConnectConfig)**: Configuration management project using this module
- **[Datum](https://github.com/gaelcolas/Datum)**: Hierarchical configuration data management
- **[DscWorkshop](https://github.com/dsccommunity/DscWorkshop)**: Enterprise DSC configuration framework
