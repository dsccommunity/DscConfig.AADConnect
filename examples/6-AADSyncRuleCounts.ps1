<#
.EXAMPLE 6

This example demonstrates the AADSyncRuleCounts composite resource which
wraps the report-only AADSyncRuleCount DSC resource from AADConnectDsc.

The resource verifies that each connector has the expected number of sync
rules. It does not create or remove sync rules to reach the expected count;
when drift is detected the LCM marks the configuration as failed and the
operator must investigate.
#>

configuration Example_DscConfig_AADSyncRuleCounts
{
    Import-DscResource -ModuleName DscConfig.AADConnect

    node localhost
    {
        $ruleCounts = @(
            @{
                ConnectorName = 'contoso.com'
                RuleCount     = 42
            },
            @{
                ConnectorName = 'fabrikam.com'
                RuleCount     = 30
            },
            # Empty ConnectorName or '*' counts rules across all connectors.
            @{
                ConnectorName = '*'
                RuleCount     = 168
            }
        )

        AADSyncRuleCounts 'CompanyRuleCounts'
        {
            Items = $ruleCounts
        }
    }
}

# Compile the configuration
Example_DscConfig_AADSyncRuleCounts -OutputPath '.\Output'