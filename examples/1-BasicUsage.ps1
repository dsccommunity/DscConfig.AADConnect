<#
.EXAMPLE 1

This example demonstrates basic usage of both DscConfig.AADConnect composite
resources with simple configuration data arrays.
#>

Configuration Example_DscConfig_BasicUsage
{
    Import-DscResource -ModuleName DscConfig.AADConnect

    Node localhost
    {
        # Define a simple array of sync rules
        $syncRules = @(
            @{
                Name                = 'Basic - Inbound - User - Employee'
                ConnectorName       = 'contoso.com'
                Direction           = 'Inbound'
                TargetObjectType    = 'person'
                SourceObjectType    = 'user'
                LinkType            = 'Provision'
                Precedence          = 10
                Disabled            = $false
                ScopeFilter         = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute           = 'employeeType'
                                ComparisonOperator  = 'EQUAL'
                                ComparisonValue     = 'Employee'
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
                        Source      = 'mail'
                        Destination = 'userPrincipalName'
                        FlowType    = 'Direct'
                    }
                )
            },
            @{
                Name                = 'Basic - Inbound - User - Manager'
                ConnectorName       = 'contoso.com'
                Direction           = 'Inbound'
                TargetObjectType    = 'person'
                SourceObjectType    = 'user'
                LinkType            = 'Provision'
                Precedence          = 15
                Disabled            = $false
                ScopeFilter         = @(
                    @{
                        ScopeConditionList = @(
                            @{
                                Attribute           = 'manager'
                                ComparisonOperator  = 'ISNOTNULL'
                                ComparisonValue     = ''
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
            }
        )

        # Use AADSyncRules composite resource to process the array
        AADSyncRules 'BasicSyncRules'
        {
            Items = $syncRules
        }

        # Define a simple array of directory extensions
        $directoryExtensions = @(
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
            }
        )

        # Use AADConnectDirectoryExtensionAttributes composite resource
        AADConnectDirectoryExtensionAttributes 'BasicExtensions'
        {
            Items = $directoryExtensions
        }
    }
}

# Compile the configuration
Example_DscConfig_BasicUsage -OutputPath "C:\DSC\BasicUsage"
