<#
.EXAMPLE 2

This example demonstrates integration with configuration management systems by
using structured configuration data that could come from YAML files or other
data sources processed by systems like Datum.
#>

# Configuration data that would typically come from external sources
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            Environment = 'Production'
        }
    )

    # Sync rules configuration data
    AADSyncRules = @{
        Items = @(
            @{
                Name                = 'HR - Inbound - User - Employee'
                ConnectorName       = 'hr.contoso.com'
                Direction           = 'Inbound'
                TargetObjectType    = 'person'
                SourceObjectType    = 'user'
                LinkType            = 'Provision'
                Precedence          = 20
                Disabled            = $false
                ScopeFilter         = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute           = 'employeeType'
                                ComparisonOperator  = 'EQUAL'
                                ComparisonValue     = 'Employee'
                            },
                            @{
                                Attribute           = 'userAccountControl'
                                ComparisonOperator  = 'NOTEQUAL'
                                ComparisonValue     = '514'
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
                        Source      = 'extensionAttribute1'
                        Destination = 'employeeID'
                        FlowType    = 'Direct'
                    }
                )
            },
            @{
                Name                = 'Finance - Inbound - User - Financial'
                ConnectorName       = 'finance.contoso.com'
                Direction           = 'Inbound'
                TargetObjectType    = 'person'
                SourceObjectType    = 'user'
                LinkType            = 'Provision'
                Precedence          = 25
                Disabled            = $false
                ScopeFilter         = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute           = 'department'
                                ComparisonOperator  = 'EQUAL'
                                ComparisonValue     = 'Finance'
                            }
                        )
                    }
                )
                AttributeFlowMappings = @(
                    @{
                        Source      = 'extensionAttribute2'
                        Destination = 'costCenter'
                        FlowType    = 'Direct'
                    },
                    @{
                        Source      = 'extensionAttribute3'
                        Destination = 'departmentCode'
                        FlowType    = 'Direct'
                    }
                )
            }
        )
    }

    # Directory extensions configuration data
    AADConnectDirectoryExtensionAttributes = @{
        Items = @(
            @{
                Name                = 'employeeID'
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
                Name                = 'managerEmail'
                AssignedObjectClass = 'user'
                Type                = 'String'
                IsEnabled           = $true
            },
            @{
                Name                = 'isContractor'
                AssignedObjectClass = 'user'
                Type                = 'Boolean'
                IsEnabled           = $true
            }
        )
    }
}

Configuration Example_DscConfig_ConfigurationManagement
{
    Import-DscResource -ModuleName DscConfig.AADConnect

    Node $AllNodes.NodeName
    {
        # Use configuration data from external source (e.g., Datum)
        AADSyncRules 'ConfigMgmtSyncRules'
        {
            Items = $ConfigurationData.AADSyncRules.Items
        }

        AADConnectDirectoryExtensionAttributes 'ConfigMgmtExtensions'
        {
            Items = $ConfigurationData.AADConnectDirectoryExtensionAttributes.Items
        }
    }
}

# Compile the configuration with configuration data
Example_DscConfig_ConfigurationManagement -ConfigurationData $ConfigurationData -OutputPath "C:\DSC\ConfigManagement"
