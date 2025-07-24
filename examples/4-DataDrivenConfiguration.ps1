<#
.EXAMPLE 4

This example demonstrates how to use external YAML/JSON data sources with the
DscConfig.AADConnect composite resources. This pattern is commonly used in
enterprise environments where configuration data is managed separately from
DSC configurations and stored in version control systems.

This example shows:
- Loading configuration from YAML files
- Processing JSON configuration data
- Integration with GitOps workflows
- Environment-specific configuration overlays
- Validation of external data sources
#>

# Function to simulate loading YAML data (in real scenarios, use powershell-yaml module)
function Get-SimulatedYamlData {
    param($FilePath)

    # This simulates what would be loaded from a YAML file
    # In practice, you would use: ConvertFrom-Yaml (Get-Content $FilePath -Raw)
    return @{
        environments = @{
            production = @{
                connectors = @('contoso.com', 'hr.contoso.com')
                syncRulePrecedenceBase = 10
                enableAdvancedFeatures = $true
            }
            test = @{
                connectors = @('test.contoso.com', 'hr-test.contoso.com')
                syncRulePrecedenceBase = 1000
                enableAdvancedFeatures = $false
            }
        }

        syncRules = @(
            @{
                name = 'HR-User-Standard'
                template = 'inbound-user-provision'
                connectorIndex = 0
                precedenceOffset = 0
                targetObjectType = 'person'
                sourceObjectType = 'user'
                scopeFilters = @(
                    @{
                        attribute = 'employeeType'
                        operator = 'EQUAL'
                        value = 'Employee'
                    }
                )
                attributeMappings = @(
                    @{ source = 'givenName'; destination = 'firstName'; flowType = 'Direct' },
                    @{ source = 'sn'; destination = 'lastName'; flowType = 'Direct' },
                    @{ source = 'extensionAttribute1'; destination = 'employeeId'; flowType = 'Direct' }
                )
            },
            @{
                name = 'Finance-User-Special'
                template = 'inbound-user-provision'
                connectorIndex = 1
                precedenceOffset = 5
                targetObjectType = 'person'
                sourceObjectType = 'user'
                scopeFilters = @(
                    @{
                        attribute = 'department'
                        operator = 'EQUAL'
                        value = 'Finance'
                    }
                )
                attributeMappings = @(
                    @{ source = 'extensionAttribute5'; destination = 'costCenter'; flowType = 'Direct' },
                    @{ source = 'extensionAttribute6'; destination = 'budgetCode'; flowType = 'Direct' }
                )
            }
        )

        directoryExtensions = @(
            @{
                name = 'employeeId'
                objectClass = 'user'
                dataType = 'String'
                required = $true
            },
            @{
                name = 'costCenter'
                objectClass = 'user'
                dataType = 'String'
                required = $false
            },
            @{
                name = 'budgetCode'
                objectClass = 'user'
                dataType = 'String'
                required = $false
            },
            @{
                name = 'projectCode'
                objectClass = 'user'
                dataType = 'String'
                required = $false
            }
        )
    }
}

# Function to simulate loading JSON data
function Get-SimulatedJsonData {
    param($FilePath)

    # This simulates what would be loaded from a JSON file
    # In practice, you would use: Get-Content $FilePath | ConvertFrom-Json
    return @{
        metadata = @{
            version = '2.1.0'
            lastUpdated = '2025-01-15'
            maintainer = 'Identity Team'
        }

        additionalSyncRules = @(
            @{
                name = 'External-Contractors'
                connectorName = 'vendors.contoso.com'
                direction = 'Inbound'
                targetObjectType = 'person'
                sourceObjectType = 'user'
                linkType = 'Provision'
                precedence = 50
                disabled = $false
                scopeFilter = @(
                    @{
                        scopeConditionList = @(
                            @{
                                attribute = 'extensionAttribute15'
                                comparisonOperator = 'EQUAL'
                                comparisonValue = 'EXTERNAL'
                            }
                        )
                    }
                )
                attributeFlowMappings = @(
                    @{
                        source = 'extensionAttribute10'
                        destination = 'contractorId'
                        flowType = 'Direct'
                    }
                )
            }
        )

        additionalExtensions = @(
            @{
                name = 'contractorId'
                assignedObjectClass = 'user'
                type = 'String'
                isEnabled = $true
            },
            @{
                name = 'externalSystem'
                assignedObjectClass = 'user'
                type = 'String'
                isEnabled = $true
            }
        )
    }
}

# Function to transform YAML/JSON data into DSC configuration format
function Convert-ExternalDataToDscConfig {
    param(
        [hashtable]$YamlData,
        [hashtable]$JsonData,
        [string]$Environment = 'production'
    )

    $envConfig = $YamlData.environments[$Environment]
    $connectors = $envConfig.connectors
    $precedenceBase = $envConfig.syncRulePrecedenceBase

    # Transform sync rules from template format to DSC format
    $syncRules = @()

    foreach ($rule in $YamlData.syncRules) {
        $dscRule = @{
            Name = "$Environment - $($rule.name)"
            ConnectorName = $connectors[$rule.connectorIndex]
            Direction = 'Inbound'
            TargetObjectType = $rule.targetObjectType
            SourceObjectType = $rule.sourceObjectType
            LinkType = 'Provision'
            Precedence = $precedenceBase + $rule.precedenceOffset
            Disabled = $false
            ScopeFilter = @()
            AttributeFlowMappings = @()
        }

        # Transform scope filters
        if ($rule.scopeFilters) {
            $scopeConditions = @()
            foreach ($filter in $rule.scopeFilters) {
                $scopeConditions += @{
                    Attribute = $filter.attribute
                    ComparisonOperator = $filter.operator
                    ComparisonValue = $filter.value
                }
            }
            $dscRule.ScopeFilter = @(@{ ScopeConditionList = $scopeConditions })
        }

        # Transform attribute mappings
        if ($rule.attributeMappings) {
            foreach ($mapping in $rule.attributeMappings) {
                $dscRule.AttributeFlowMappings += @{
                    Source = $mapping.source
                    Destination = $mapping.destination
                    FlowType = $mapping.flowType
                }
            }
        }

        $syncRules += $dscRule
    }

    # Add JSON-based sync rules
    $syncRules += $JsonData.additionalSyncRules

    # Transform directory extensions
    $extensions = @()
    foreach ($ext in $YamlData.directoryExtensions) {
        $extensions += @{
            Name = $ext.name
            AssignedObjectClass = $ext.objectClass
            Type = $ext.dataType
            IsEnabled = $true
        }
    }

    # Add JSON-based extensions
    $extensions += $JsonData.additionalExtensions

    return @{
        SyncRules = $syncRules
        DirectoryExtensions = $extensions
        Metadata = $JsonData.metadata
    }
}

# Load external data sources
Write-Host "Loading configuration from external data sources..." -ForegroundColor Green

# In real scenarios, these would be actual file paths:
# $yamlData = Get-Content "C:\Config\AADConnect\sync-config.yaml" -Raw | ConvertFrom-Yaml
# $jsonData = Get-Content "C:\Config\AADConnect\additional-config.json" -Raw | ConvertFrom-Json

$yamlData = Get-SimulatedYamlData -FilePath "sync-config.yaml"
$jsonData = Get-SimulatedJsonData -FilePath "additional-config.json"

# Validate external data before processing
function Test-ConfigurationData {
    param([hashtable]$Data)

    Write-Host "Validating configuration data..." -ForegroundColor Yellow

    $valid = $true

    # Validate sync rules
    foreach ($rule in $Data.SyncRules) {
        if (-not $rule.Name -or -not $rule.ConnectorName) {
            Write-Warning "Invalid sync rule found: Missing Name or ConnectorName"
            $valid = $false
        }
        if ($rule.Precedence -lt 1 -or $rule.Precedence -gt 99999) {
            Write-Warning "Invalid precedence value: $($rule.Precedence)"
            $valid = $false
        }
    }

    # Validate directory extensions
    foreach ($ext in $Data.DirectoryExtensions) {
        if (-not $ext.Name -or -not $ext.AssignedObjectClass) {
            Write-Warning "Invalid directory extension: Missing Name or AssignedObjectClass"
            $valid = $false
        }
    }

    if ($valid) {
        Write-Host "✓ Configuration data validation passed" -ForegroundColor Green
    } else {
        Write-Error "Configuration data validation failed"
        throw "Invalid configuration data"
    }

    return $valid
}

# Process data for different environments
$environments = @('production', 'test')

foreach ($env in $environments) {
    Write-Host "`nProcessing configuration for environment: $env" -ForegroundColor Cyan

    # Transform external data to DSC format
    $dscConfig = Convert-ExternalDataToDscConfig -YamlData $yamlData -JsonData $jsonData -Environment $env

    # Validate the processed configuration
    Test-ConfigurationData -Data $dscConfig

    # Create configuration data for DSC
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                Environment = $env
                ConfigVersion = $dscConfig.Metadata.version
                LastUpdated = $dscConfig.Metadata.lastUpdated
            }
        )
        AADSyncRules = @{
            Items = $dscConfig.SyncRules
        }
        AADConnectDirectoryExtensionAttributes = @{
            Items = $dscConfig.DirectoryExtensions
        }
    }

    # DSC Configuration
    Configuration Example_DscConfig_DataDriven
    {
        Import-DscResource -ModuleName DscConfig.AADConnect

        Node $AllNodes.NodeName
        {
            # Apply sync rules from external data sources
            AADSyncRules "DataDrivenSyncRules_$($Node.Environment)"
            {
                Items = $ConfigurationData.AADSyncRules.Items
            }

            # Apply directory extensions from external data sources
            AADConnectDirectoryExtensionAttributes "DataDrivenExtensions_$($Node.Environment)"
            {
                Items = $ConfigurationData.AADConnectDirectoryExtensionAttributes.Items
            }
        }
    }

    # Compile configuration
    $outputPath = "C:\DSC\DataDriven\$env"
    Write-Host "Compiling DSC configuration to: $outputPath" -ForegroundColor Green
    Example_DscConfig_DataDriven -ConfigurationData $ConfigurationData -OutputPath $outputPath

    # Display summary
    Write-Host @"
Environment: $env
- Sync Rules: $($dscConfig.SyncRules.Count)
- Directory Extensions: $($dscConfig.DirectoryExtensions.Count)
- Configuration Version: $($dscConfig.Metadata.version)
- Output Path: $outputPath
"@ -ForegroundColor White
}

# Example GitOps integration function
function Invoke-GitOpsConfigurationUpdate {
    param(
        [string]$GitRepoPath = "C:\GitOps\AADConnect-Config",
        [string]$Environment = "production"
    )

    Write-Host "`nGitOps Configuration Update Example" -ForegroundColor Magenta
    Write-Host "This demonstrates how to integrate with GitOps workflows:" -ForegroundColor White

    $steps = @(
        "1. Pull latest configuration from Git repository",
        "2. Validate YAML/JSON configuration files",
        "3. Transform external data to DSC configuration format",
        "4. Compile and test DSC configuration",
        "5. Deploy to target environment",
        "6. Update deployment status in Git repository"
    )

    foreach ($step in $steps) {
        Write-Host "   $step" -ForegroundColor Gray
    }

    Write-Host "`nExample commands for GitOps integration:" -ForegroundColor Yellow
    Write-Host "   git pull origin main" -ForegroundColor Gray
    Write-Host "   .\Invoke-ConfigValidation.ps1 -Environment $Environment" -ForegroundColor Gray
    Write-Host "   .\Deploy-AADConnectConfig.ps1 -Environment $Environment" -ForegroundColor Gray
    Write-Host "   git tag 'deploy-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')'" -ForegroundColor Gray
}

# Demonstrate GitOps integration
Invoke-GitOpsConfigurationUpdate

Write-Host @"

Data-Driven Configuration Complete!

This example demonstrates:
✓ Loading configuration from external YAML/JSON sources
✓ Data validation and transformation
✓ Multi-environment deployment from same source data
✓ Integration with GitOps workflows
✓ Separation of configuration data from DSC code

Key Benefits:
- Configuration data is version-controlled separately
- Same DSC code works across all environments
- Non-PowerShell teams can maintain configuration data
- Automated validation prevents deployment errors
- Supports GitOps and Infrastructure as Code practices

External Data Sources Used:
- YAML: Primary sync rule templates and environment config
- JSON: Additional rules and metadata
- Environment-specific overlays for precedence and connectors

"@ -ForegroundColor Cyan
