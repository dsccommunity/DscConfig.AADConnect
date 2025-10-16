<#
.EXAMPLE 3

This example demonstrates a complete real-world scenario with multiple
environments, complex sync rules for different organizational units, and
comprehensive directory extensions supporting enterprise identity management.

This scenario covers:
- Multi-environment configuration (Dev/Test/Prod)
- Complex sync rules with advanced filtering
- Comprehensive directory extensions for HR integration
- Exchange hybrid attributes
- Security group management
- Manager hierarchies
#>

# Real-world configuration data representing enterprise AAD Connect setup
$RealWorldConfigurationData = @{
    AllNodes                               = @(
        @{
            NodeName     = 'localhost'
            Environment  = 'Production'
            Organization = 'Contoso Corporation'
        }
    )

    # Complex sync rules for enterprise scenarios
    AADSyncRules                           = @{
        Items = @(
            # Primary user provisioning from on-premises AD
            @{
                Name                  = 'Enterprise - Inbound - User - Standard Employee'
                ConnectorName         = 'contoso.com'
                Direction             = 'Inbound'
                TargetObjectType      = 'person'
                SourceObjectType      = 'user'
                LinkType              = 'Provision'
                Precedence            = 10
                Disabled              = $false
                ScopeFilter           = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute          = 'employeeType'
                                ComparisonOperator = 'EQUAL'
                                ComparisonValue    = 'Employee'
                            },
                            @{
                                Attribute          = 'userAccountControl'
                                ComparisonOperator = 'NOTEQUAL'
                                ComparisonValue    = '514'
                            },
                            @{
                                Attribute          = 'extensionAttribute15'
                                ComparisonOperator = 'NOTEQUAL'
                                ComparisonValue    = 'EXCLUDE_FROM_SYNC'
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source      = 'givenName'
                        Destination = 'firstName'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'sn'
                        Destination = 'lastName'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'userPrincipalName'
                        Destination = 'userPrincipalName'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'extensionAttribute1'
                        Destination = 'employeeId'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'department'
                        Destination = 'department'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'title'
                        Destination = 'jobTitle'
                        FlowType    = 'Direct'
                    }
                )
            },

            # Contractor/vendor user provisioning
            @{
                Name                  = 'Enterprise - Inbound - User - Contractor'
                ConnectorName         = 'contractors.contoso.com'
                Direction             = 'Inbound'
                TargetObjectType      = 'person'
                SourceObjectType      = 'user'
                LinkType              = 'Provision'
                Precedence            = 15
                Disabled              = $false
                ScopeFilter           = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute          = 'employeeType'
                                ComparisonOperator = 'EQUAL'
                                ComparisonValue    = 'Contractor'
                            },
                            @{
                                Attribute          = 'extensionAttribute10'
                                ComparisonOperator = 'ISNOTNULL'
                                ComparisonValue    = ''
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source      = 'givenName'
                        Destination = 'firstName'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'sn'
                        Destination = 'lastName'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'extensionAttribute10'
                        Destination = 'contractorId'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'extensionAttribute11'
                        Destination = 'vendorCompany'
                        FlowType    = 'Direct'
                    }
                )
            },

            # Manager relationship sync rule
            @{
                Name                  = 'Enterprise - Inbound - User - Manager Hierarchy'
                ConnectorName         = 'contoso.com'
                Direction             = 'Inbound'
                TargetObjectType      = 'person'
                SourceObjectType      = 'user'
                LinkType              = 'Provision'
                Precedence            = 20
                Disabled              = $false
                ScopeFilter           = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute          = 'manager'
                                ComparisonOperator = 'ISNOTNULL'
                                ComparisonValue    = ''
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source      = 'manager'
                        Destination = 'manager'
                        FlowType    = 'Direct'
                    }
                )
            },

            # Security group provisioning
            @{
                Name                  = 'Enterprise - Inbound - Group - Security Groups'
                ConnectorName         = 'contoso.com'
                Direction             = 'Inbound'
                TargetObjectType      = 'group'
                SourceObjectType      = 'group'
                LinkType              = 'Provision'
                Precedence            = 30
                Disabled              = $false
                ScopeFilter           = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute          = 'groupType'
                                ComparisonOperator = 'EQUAL'
                                ComparisonValue    = '2147483650'
                            },
                            @{
                                Attribute          = 'extensionAttribute5'
                                ComparisonOperator = 'EQUAL'
                                ComparisonValue    = 'SYNC_TO_AAD'
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source      = 'displayName'
                        Destination = 'displayName'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'description'
                        Destination = 'description'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'member'
                        Destination = 'member'
                        FlowType    = 'Direct'
                    }
                )
            },

            # Exchange hybrid mail attributes
            @{
                Name                  = 'Enterprise - Inbound - User - Exchange Attributes'
                ConnectorName         = 'contoso.com'
                Direction             = 'Inbound'
                TargetObjectType      = 'person'
                SourceObjectType      = 'user'
                LinkType              = 'Provision'
                Precedence            = 25
                Disabled              = $false
                ScopeFilter           = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute          = 'mailNickname'
                                ComparisonOperator = 'ISNOTNULL'
                                ComparisonValue    = ''
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source      = 'mail'
                        Destination = 'mail'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'mailNickname'
                        Destination = 'mailNickname'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'proxyAddresses'
                        Destination = 'proxyAddresses'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'msExchHideFromAddressLists'
                        Destination = 'msExchHideFromAddressLists'
                        FlowType    = 'Direct'
                    }
                )
            }
        )
    }

    # Comprehensive directory extensions for enterprise scenarios
    AADConnectDirectoryExtensionAttributes = @{
        Items = @(
            # HR System Integration Extensions
            @{
                Name                = 'employeeId'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'costCenter'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'departmentCode'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'businessUnit'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'location'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'building'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'floor'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },

            # Security and Compliance Extensions
            @{
                Name                = 'securityClearance'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'dataClassification'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'complianceFlag'
                AssignedObjectClass = 'user'
                Type                = 'Boolean'
                IsEnabled           = $true
            },

            # Contractor Management Extensions
            @{
                Name                = 'contractorId'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'vendorCompany'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'contractEndDate'
                AssignedObjectClass = 'user'
                Type                = 'DateTime'
                IsEnabled           = $true
            },

            # Manager and Hierarchy Extensions
            @{
                Name                = 'managerEmployeeId'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'functionalManager'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },

            # Application-Specific Extensions
            @{
                Name                = 'sapPersonnelNumber'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'workdayId'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'servicenowUserId'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            }
        )
    }
}

configuration Example_DscConfig_RealWorldScenario
{
    Import-DscResource -ModuleName DscConfig.AADConnect

    node $AllNodes.NodeName
    {
        # Deploy comprehensive sync rules for enterprise scenario
        AADSyncRules 'EnterpriseSync'
        {
            Items = $ConfigurationData.AADSyncRules.Items
        }

        # Deploy comprehensive directory extensions for enterprise integration
        AADConnectDirectoryExtensionAttributes 'EnterpriseExtensions'
        {
            Items = $ConfigurationData.AADConnectDirectoryExtensionAttributes.Items
        }
    }
}

# Example: Compile configuration for different environments
# This demonstrates how the same configuration can be used across environments
# with environment-specific data

# Production deployment
Write-Host 'Compiling Real-World Scenario for Production...' -ForegroundColor Green
Example_DscConfig_RealWorldScenario -ConfigurationData $RealWorldConfigurationData -OutputPath 'C:\DSC\RealWorld\Production'

# Test environment with modified precedence values
$TestConfigData = $RealWorldConfigurationData.Clone()
foreach ($syncRule in $TestConfigData.AADSyncRules.Items)
{
    $syncRule.Precedence += 1000  # Offset precedence for test environment
}

Write-Host 'Compiling Real-World Scenario for Test Environment...' -ForegroundColor Yellow
Example_DscConfig_RealWorldScenario -ConfigurationData $TestConfigData -OutputPath 'C:\DSC\RealWorld\Test'

Write-Host @'

Real-World Scenario Configuration Complete!

This configuration includes:
✓ Multi-tier user provisioning (Employees, Contractors, Managers)
✓ Security group synchronization with filtering
✓ Exchange hybrid mail attribute mapping
✓ Comprehensive directory extensions for enterprise systems
✓ Environment-specific deployment examples

Key Features Demonstrated:
- Complex scope filtering with multiple conditions
- Advanced attribute flow mapping patterns
- Enterprise directory extension schema
- Multi-environment deployment strategies
- Integration points for major enterprise systems (SAP, Workday, ServiceNow)

'@ -ForegroundColor Cyan
