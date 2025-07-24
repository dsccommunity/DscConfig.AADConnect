<#
.EXAMPLE 5

This example demonstrates integration with DscWorkshop and Datum configuration
management frameworks, following the same patterns used in the AADConnectConfig
project. This shows how DscConfig.AADConnect composite resources are consumed
by enterprise configuration management systems using hierarchical YAML
configuration data and Datum's data merging capabilities.

This example covers:
- Datum hierarchical configuration structure with real YAML files
- DscWorkshop integration patterns
- Environment-specific configuration precedence
- Connector-based rule organization
- PowerShell code execution in YAML (Datum.InvokeCommand)
- Advanced merge strategies for complex configurations
#>

Write-Host "=== DscWorkshop/Datum Integration Example ===" -ForegroundColor Cyan
Write-Host "This example shows the YAML configuration structure used in enterprise deployments" -ForegroundColor Green

#region 1. Datum Configuration (source/Datum.yml)

Write-Host "`n=== 1. Datum Configuration Structure ===" -ForegroundColor Yellow

$DatumYamlContent = @"
# source/Datum.yml
# This file defines how Datum resolves and merges configuration data

ResolutionPrecedence:
  - AllNodes\`$(`$Node.Environment)\`$(`$Node.NodeName)
  - Environments\`$(`$Node.Environment)
  - '[x={ foreach (`$name in `$Node.ConnectorNames) { "Connectors\`$name" } }=]'
  - Baselines\DscLcm

DatumHandlersThrowOnError: true
DatumHandlers:
  Datum.ProtectedData::ProtectedDatum:
    CommandOptions:
      PlainTextPassword: SomeSecret
  Datum.InvokeCommand::InvokeCommand:
    SkipDuringLoad: true

DscLocalConfigurationManagerKeyName: LcmConfig

default_lookup_options: MostSpecific

lookup_options:
  AADSyncRules:
    merge_hash: deep
  AADSyncRules\Items:
    merge_hash_array: DeepTuple
    merge_options:
      tuple_keys:
        - Name
        - ConnectorName

  AADConnectDirectoryExtensionAttributes:
    merge_hash: deep
  AADConnectDirectoryExtensionAttributes\Items:
    merge_hash_array: DeepTuple
    merge_options:
      tuple_keys:
        - Name
        - AssignedObjectClass

  DscTagging:
    merge_hash: deep
  DscTagging\Layers:
    merge_basetype_array: Unique
"@

Write-Host $DatumYamlContent -ForegroundColor Gray

#endregion

#region 2. Node Configuration (AllNodes layer - Highest Precedence)

Write-Host "`n=== 2. Node Configuration (Highest Precedence) ===" -ForegroundColor Yellow
Write-Host "File: source/AllNodes/ProdCore/AADConnect01.contoso.com.yml" -ForegroundColor White

$NodeConfigYaml = @"
# source/AllNodes/ProdCore/AADConnect01.contoso.com.yml
# Node-specific configuration with highest precedence

NodeName: "[x={ `$Node.Name }=]"
Environment: "[x={ `$File.Directory.BaseName } =]"
Description: '[x= "`$(`$Node.Role) in `$(`$Node.Environment)" =]'
ConnectorNames:
  - contoso.com
  - fabrikam.com

# Node-specific AAD Sync Rules (override environment/connector rules)
AADSyncRules:
  Items:
    - Name: 'Custom - Node Override - Critical Users'
      ConnectorName: contoso.com
      Direction: Inbound
      TargetObjectType: person
      SourceObjectType: user
      LinkType: Provision
      Precedence: 5
      Disabled: false
      ScopeFilter:
        - ScopeConditionList:
            - Attribute: extensionAttribute15
              ComparisonOperator: EQUAL
              ComparisonValue: 'CRITICAL_NODE_OVERRIDE'
      AttributeFlowMappings:
        - Source: displayName
          Destination: displayName
          FlowType: Direct
          ExecuteOnce: false
          Expression: null
          ValueMergeType: Update

# Node-specific Directory Extensions
AADConnectDirectoryExtensionAttributes:
  Items:
    - Name: nodeSpecificId
      AssignedObjectClass: user
      Type: String
      IsEnabled: true

DscTagging:
  Environment: '[x={ `$Node.Environment } =]'
  Layers:
    - '[x={ Get-DatumSourceFile -Path `$File } =]'

PSDscAllowPlainTextPassword: true
PSDscAllowDomainUser: true

LcmConfig:
  ConfigurationRepositoryWeb:
    Server:
      ConfigurationNames: "[x={ `$Node.NodeName }=]"
"@

Write-Host $NodeConfigYaml -ForegroundColor Gray

#endregion

#region 3. Environment Configuration (Environment layer)

Write-Host "`n=== 3. Environment Configuration ===" -ForegroundColor Yellow
Write-Host "File: source/Environments/ProdCore.yml" -ForegroundColor White

$EnvironmentConfigYaml = @"
# source/Environments/ProdCore.yml
# Production environment-specific configuration

# Environment-level AAD Sync Rules
AADSyncRules:
  Items:
    - Name: 'Prod - Security - High Clearance Users'
      ConnectorName: contoso.com
      Direction: Inbound
      TargetObjectType: person
      SourceObjectType: user
      LinkType: Provision
      Precedence: 12
      Disabled: false
      ScopeFilter:
        - ScopeConditionList:
            - Attribute: extensionAttribute10
              ComparisonOperator: EQUAL
              ComparisonValue: 'HIGH_CLEARANCE'
            - Attribute: userAccountControl
              ComparisonOperator: NOTEQUAL
              ComparisonValue: '514'
      AttributeFlowMappings:
        - Source: extensionAttribute11
          Destination: securityClearance
          FlowType: Direct
          ExecuteOnce: false
          Expression: null
          ValueMergeType: Update

# Production-specific Directory Extensions
AADConnectDirectoryExtensionAttributes:
  Items:
    - Name: environment
      AssignedObjectClass: user
      Type: String
      IsEnabled: true
    - Name: deploymentStage
      AssignedObjectClass: user
      Type: String
      IsEnabled: true
    - Name: productionMarker
      AssignedObjectClass: user
      Type: Boolean
      IsEnabled: true

DscTagging:
  Environment: '[x={ `$Node.Environment } =]'
  Layers:
    - '[x={ Get-DatumSourceFile -Path `$File } =]'
"@

Write-Host $EnvironmentConfigYaml -ForegroundColor Gray

#endregion

#region 4. Connector Configuration (Dynamic Processing)

Write-Host "`n=== 4. Connector Configuration (Dynamic Processing) ===" -ForegroundColor Yellow
Write-Host "File: source/Connectors/contoso.com.yml" -ForegroundColor White

$ConnectorConfigYaml = @"
# source/Connectors/contoso.com.yml
# Connector-specific configuration with dynamic rule processing

DscTagging:
  Environment: "[x={ `$Node.Environment } =]"
  Layers:
    - "[x={ Get-DatumSourceFile -Path `$File } =]"

# Dynamic rule processing using Datum.InvokeCommand
AADSyncRules:
  Items:
    - |
      '[x={ & "`$ScriptsDirectory\Connector.ps1" } =]'

# Connector-specific Directory Extensions
AADConnectDirectoryExtensionAttributes:
  Items:
    - Name: sourceConnector
      AssignedObjectClass: user
      Type: String
      IsEnabled: true
    - Name: syncTimestamp
      AssignedObjectClass: user
      Type: DateTime
      IsEnabled: true
"@

Write-Host $ConnectorConfigYaml -ForegroundColor Gray

Write-Host "`nFile: source/Scripts/Connector.ps1 (PowerShell code executed by Datum)" -ForegroundColor White

$ConnectorScriptContent = @"
# source/Scripts/Connector.ps1
# This script is executed by Datum.InvokeCommand to process connector rules

`$connectorName = `$File.BaseName
Write-Host "Processing connector: `$connectorName" -ForegroundColor Magenta
`$rules = `$datum.RuleMapping.`$connectorName
Write-Host "`tFound `$(`$rules.Count) rules for connector '`$connectorName'"

`$rules = foreach (`$rule in `$rules) {
    `$ruleFile = Get-ChildItem -Path `$PWD\source\SyncRules\ -Filter "`$rule.yml" -Recurse
    if (`$null -eq `$ruleFile) {
        Write-Error "Rule '`$rule' could not be found in the 'SyncRules' folder."
    }

    `$rule = Get-Content -Path `$ruleFile.FullName -Raw | ConvertFrom-Yaml
    `$rule.ConnectorName = `$connectorName

    if (-not `$rule.IsStandardRule) {
        `$rule.Precedence = `$global:precedenceCount
        `$global:precedenceCount++
    }

    `$rule
}

`$rules
"@

Write-Host $ConnectorScriptContent -ForegroundColor Gray

#endregion

#region 5. Rule Mapping Configuration

Write-Host "`n=== 5. Rule Mapping Configuration ===" -ForegroundColor Yellow
Write-Host "File: source/RuleMapping/contoso.com.yml" -ForegroundColor White

$RuleMappingYaml = @"
# source/RuleMapping/contoso.com.yml
# Defines which sync rules apply to this connector

- Contoso - Inbound - UserJoin - AD
- Contoso - Inbound - UserCommon - AD
- In from AD - User Common
- Custom - Inbound - User - Employee
- Custom - Inbound - User - Manager
"@

Write-Host $RuleMappingYaml -ForegroundColor Gray

#endregion

#region 6. Individual Sync Rule Definition

Write-Host "`n=== 6. Individual Sync Rule Definition ===" -ForegroundColor Yellow
Write-Host "File: source/SyncRules/Custom - Inbound - User - Employee.yml" -ForegroundColor White

$SyncRuleYaml = @"
# source/SyncRules/Custom - Inbound - User - Employee.yml
# Individual sync rule definition

Name: Custom - Inbound - User - Employee
Description: 'Custom rule for employee provisioning'
Direction: Inbound
Disabled: false
SourceObjectType: user
TargetObjectType: person
Precedence: 20
LinkType: Provision
EnablePasswordSync: false
JoinFilter: []
ScopeFilter:
  - ScopeConditionList:
      - Attribute: employeeType
        ComparisonValue: Employee
        ComparisonOperator: EQUAL
      - Attribute: userAccountControl
        ComparisonValue: '514'
        ComparisonOperator: NOTEQUAL
AttributeFlowMappings:
  - Source: givenName
    Destination: firstName
    FlowType: Direct
    ExecuteOnce: false
    Expression: null
    ValueMergeType: Update
  - Source: sn
    Destination: lastName
    FlowType: Direct
    ExecuteOnce: false
    Expression: null
    ValueMergeType: Update
  - Source: userPrincipalName
    Destination: userPrincipalName
    FlowType: Direct
    ExecuteOnce: false
    Expression: null
    ValueMergeType: Update
  - Source: extensionAttribute1
    Destination: employeeId
    FlowType: Direct
    ExecuteOnce: false
    Expression: null
    ValueMergeType: Update
IsStandardRule: false
"@

Write-Host $SyncRuleYaml -ForegroundColor Gray

#endregion

#region 7. Baseline Configuration (Lowest Precedence)

Write-Host "`n=== 7. Baseline Configuration (Lowest Precedence) ===" -ForegroundColor Yellow
Write-Host "File: source/Baselines/DscLcm.yml" -ForegroundColor White

$BaselineConfigYaml = @"
# source/Baselines/DscLcm.yml
# Default configuration applied to all nodes

LcmConfig:
  Settings:
    RefreshMode: Push
    RefreshFrequencyMins: 30
    RebootNodeIfNeeded: true
    ActionAfterReboot: ContinueConfiguration
    AllowModuleOverwrite: true
    ConfigurationMode: ApplyAndMonitor
    ConfigurationModeFrequencyMins: 30
  ConfigurationRepositoryWeb:
    Server:
      ServerURL: https://dscpull01.contoso.com:8080/PSDSCPullServer.svc
      RegistrationKey: ec717ee9-b343-49ee-98a2-26e53939eecf
  ReportServerWeb:
      ServerURL: https://dscpull01.contoso.com:8080/PSDSCPullServer.svc
      RegistrationKey: ec717ee9-b343-49ee-98a2-26e53939eecf

# Default Directory Extensions for all environments
AADConnectDirectoryExtensionAttributes:
  Items:
    - Name: created
      AssignedObjectClass: user
      Type: DateTime
      IsEnabled: true
    - Name: lastModified
      AssignedObjectClass: user
      Type: DateTime
      IsEnabled: true

DscTagging:
  Environment: '[x={ `$Node.Environment } =]'
  Layers:
    - '[x={ Get-DatumSourceFile -Path `$File } =]'
  Version: 0.1.0

Configurations:
  - AADSyncRules
  - DscTagging
"@

Write-Host $BaselineConfigYaml -ForegroundColor Gray

#endregion

#region 8. DSC Configuration Using DscConfig.AADConnect

Write-Host "`n=== 8. DSC Configuration Implementation ===" -ForegroundColor Yellow
Write-Host "How DscConfig.AADConnect consumes the merged YAML data" -ForegroundColor White

$DscConfigurationExample = @"
# DSC Configuration using DscConfig.AADConnect composite resources
# This configuration consumes the merged YAML data from Datum

Configuration AADConnect_DscWorkshop_Integration {
    param(
        [Parameter(Mandatory)]
        [hashtable[]]`$AllNodes
    )

    Import-DscResource -ModuleName DscConfig.AADConnect
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node `$AllNodes.NodeName {

        # Configure LCM from baseline configuration
        LocalConfigurationManager {
            ConfigurationMode = `$Node.LcmConfig.Settings.ConfigurationMode
            RefreshMode = `$Node.LcmConfig.Settings.RefreshMode
            RebootNodeIfNeeded = `$Node.LcmConfig.Settings.RebootNodeIfNeeded
        }

        # Process merged sync rules using DscConfig.AADConnect
        AADSyncRules 'MergedSyncRules' {
            Items = `$ConfigurationData.AADSyncRules.Items
        }

        # Process merged directory extensions using DscConfig.AADConnect
        AADConnectDirectoryExtensionAttributes 'MergedExtensions' {
            Items = `$ConfigurationData.AADConnectDirectoryExtensionAttributes.Items
        }
    }
}

# Compilation would be:
# AADConnect_DscWorkshop_Integration -ConfigurationData `$ConfigurationData -OutputPath "C:\DSC\Output"
"@

Write-Host $DscConfigurationExample -ForegroundColor Gray

#endregion

#region 9. Data Merging Process

Write-Host "`n=== 9. Datum Data Merging Process ===" -ForegroundColor Yellow

Write-Host @"
Datum Resolution Precedence (Most Specific to Most Generic):

1. AllNodes\ProdCore\AADConnect01.contoso.com.yml    (Node Override)
   └─ Custom sync rule with Precedence: 5 (highest priority)
   └─ Node-specific directory extension (nodeSpecificId)

2. Environments\ProdCore.yml                         (Environment)
   └─ Production security rules with Precedence: 12
   └─ Environment-specific extensions (environment, deploymentStage, productionMarker)

3. Connectors\contoso.com.yml                        (Connector - Dynamic)
   └─ Standard and custom rules processed via PowerShell script
   └─ Connector-specific extensions (sourceConnector, syncTimestamp)

4. Baselines\DscLcm.yml                             (Baseline)
   └─ Default LCM configuration
   └─ Base directory extensions (created, lastModified)

Merge Strategies:
- AADSyncRules\Items: DeepTuple merge by (Name, ConnectorName)
- AADConnectDirectoryExtensionAttributes\Items: DeepTuple merge by (Name, AssignedObjectClass)
- Higher precedence layers override lower precedence layers
"@ -ForegroundColor Cyan

#endregion

#region 10. Integration Benefits

Write-Host "`n=== 10. Integration Benefits ===" -ForegroundColor Yellow

Write-Host @"
✓ Hierarchical Configuration Management
  - Environment-specific overrides (Dev/Test/Prod)
  - Node-specific customizations
  - Connector-based rule organization

✓ Dynamic Configuration Processing
  - PowerShell code execution in YAML (Datum.InvokeCommand)
  - Runtime rule mapping and precedence calculation
  - Conditional configuration based on environment

✓ Advanced Data Merging
  - DeepTuple merge prevents duplicates
  - Tuple keys ensure proper conflict resolution
  - Most specific precedence for overrides

✓ Enterprise Patterns
  - Separation of concerns (rules, mappings, baselines)
  - Version control friendly structure
  - Infrastructure as Code compliance

✓ DscConfig.AADConnect Integration
  - Composite resources handle bulk processing
  - Automatic execution name generation
  - Seamless consumption of merged YAML data
  - Standard DSC patterns with enterprise configuration management
"@ -ForegroundColor Green

#endregion

Write-Host @"

=== DscWorkshop/Datum Integration Complete! ===

This example demonstrates the real YAML configuration structure used in
enterprise Azure AD Connect deployments with DscWorkshop and Datum.

Key Components Shown:
• Datum.yml configuration with resolution precedence and merge strategies
• Hierarchical YAML files (AllNodes/Environments/Connectors/Baselines)
• Dynamic PowerShell code execution in YAML configurations
• Real sync rule definitions with complex scope filters and attribute mappings
• Rule mapping system for connector-based organization
• LCM configuration management from baseline layer
• DscConfig.AADConnect consumption of merged configuration data

This structure enables enterprise-scale configuration management with:
- Environment separation and inheritance
- Dynamic rule processing and precedence calculation
- Advanced merge behaviors for complex data structures
- Infrastructure as Code best practices
- Seamless integration with DSC composite resources

"@ -ForegroundColor Cyan
