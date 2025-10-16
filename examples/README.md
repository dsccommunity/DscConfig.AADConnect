# DscConfig.AADConnect Examples

This directory contains practical examples demonstrating how to use the DscConfig.AADConnect composite resources in various scenarios.

## Example Files

### [1-BasicUsage.ps1](1-BasicUsage.ps1)

Basic example showing simple usage of both composite resources with minimal configuration data.

### [2-ConfigurationManagement.ps1](2-ConfigurationManagement.ps1)

Advanced example demonstrating integration with configuration management systems using structured data.

### [3-RealWorldScenario.ps1](3-RealWorldScenario.ps1)

Complete real-world scenario with multiple environments, complex sync rules, and comprehensive directory extensions.

### [4-DataDrivenConfiguration.ps1](4-DataDrivenConfiguration.ps1)

Example showing how to use external YAML/JSON data sources with the composite resources.

### [5-DscWorkshopDatumIntegration.ps1](5-DscWorkshopDatumIntegration.ps1)

Complete example demonstrating integration with DscWorkshop and Datum frameworks, including hierarchical configuration data, merge strategies, and enterprise patterns.

## Usage

Each example includes:

- Complete PowerShell DSC configuration
- Sample configuration data
- Comments explaining key concepts
- Best practices demonstrations

To use these examples:

1. Review the configuration requirements in each file
2. Modify the configuration data to match your environment
3. Compile the configuration using `.\ExampleName.ps1`
4. Apply the resulting MOF files using `Start-DscConfiguration`

## Prerequisites

- DscConfig.AADConnect module installed
- AADConnectDsc module installed
- Azure AD Connect installed and configured
- Appropriate permissions for sync rule management
