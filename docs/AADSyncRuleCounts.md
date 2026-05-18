# AADSyncRuleCounts Composite Resource

## Description

The `AADSyncRuleCounts` composite resource processes arrays of Azure AD Connect
sync-rule-count expectations and generates individual `AADSyncRuleCount` DSC
resource instances. It is intended for bulk drift detection: each item declares
the expected number of sync rules for a given connector (or across all
connectors) and the underlying [AADSyncRuleCount](https://github.com/dsccommunity/AADConnectDsc) resource reports a configuration failure
when the actual count diverges from the expected count.

> [!NOTE]
> The underlying `AADSyncRuleCount` resource is **report-only**. It does not
> create or remove sync rules to reach the expected count. When drift is
> detected the LCM marks the configuration as failed and the operator must
> investigate manually.

## Parameters

### Items

- **Type**: `hashtable[]`
- **Required**: Yes
- **Description**: Array of hashtables describing the expected sync-rule counts.

Each hashtable must contain the parameters required by the underlying
`AADSyncRuleCount` resource:

| Property        | Type     | Required | Description |
|-----------------|----------|----------|-------------|
| `ConnectorName` | `string` | Yes (key) | Name of the AAD Connect connector to scope the count to. Use an empty string or `'*'` to count rules across **all** connectors. |
| `RuleCount`     | `uint32` | Yes      | The expected number of sync rules for the scope. |

## Behavior

### Execution Name Generation

Execution names are generated using the pattern:

```text
AADSyncRuleCount__{scope}
```

Where `{scope}` is the value of `ConnectorName`, except that an empty string or
`'*'` is mapped to the literal token `AllConnectors` so the name remains a
valid, unique resource identifier. Special characters (whitespace, brackets,
slashes, colons, dashes) are replaced with `_` using the regex pattern
`[\s(){}/\\:-]`.

Examples:

| `ConnectorName` value | Generated execution name              |
|-----------------------|---------------------------------------|
| `contoso.com`         | `AADSyncRuleCount__contoso.com`       |
| `fabrikam.com`        | `AADSyncRuleCount__fabrikam.com`      |
| `''` (empty)          | `AADSyncRuleCount__AllConnectors`     |
| `*`                   | `AADSyncRuleCount__AllConnectors`     |

### Resource Delegation

Each item is passed to a single `AADSyncRuleCount` resource instance via the
`Get-DscSplattedResource` utility. The composite performs no validation beyond
ensuring the items are processable; the underlying resource is responsible for
key/type validation.

## Examples

### Example 1: Per-connector count check

```powershell
Configuration BasicRuleCounts {
    Import-DscResource -ModuleName DscConfig.AADConnect

    Node localhost {
        AADSyncRuleCounts 'CompanyRuleCounts' {
            Items = @(
                @{ ConnectorName = 'contoso.com';  RuleCount = 42 }
                @{ ConnectorName = 'fabrikam.com'; RuleCount = 30 }
            )
        }
    }
}
```

### Example 2: Total count across all connectors

```powershell
Configuration TotalRuleCount {
    Import-DscResource -ModuleName DscConfig.AADConnect

    Node localhost {
        AADSyncRuleCounts 'TotalCount' {
            Items = @(
                @{ ConnectorName = '*'; RuleCount = 168 }
            )
        }
    }
}
```

### Example 3: Configuration-management integration

```yaml
# Datum / DscWorkshop configuration data
AADSyncRuleCounts:
  Items:
    - ConnectorName: contoso.com
      RuleCount: 42
    - ConnectorName: fabrikam.com
      RuleCount: 30
    - ConnectorName: '*'
      RuleCount: 168
```

```powershell
Configuration DataDrivenRuleCounts {
    Import-DscResource -ModuleName DscConfig.AADConnect

    Node $AllNodes.NodeName {
        AADSyncRuleCounts 'RuleCounts' {
            Items = $ConfigurationData.AADSyncRuleCounts.Items
        }
    }
}
```

## Related Resources

- [AADSyncRuleCount](https://github.com/dsccommunity/AADConnectDsc) — the
  underlying report-only DSC resource provided by `AADConnectDsc`.
- [AADSyncRules](AADSyncRules.md) — companion composite resource that manages
  the sync rules themselves.

## Notes

- This composite resource runs during DSC configuration compilation.
- The companion `AADSyncRuleCount` resource ships with `AADConnectDsc`
  starting with the version that introduces report-only count drift detection.
  If your installed `AADConnectDsc` predates that version, compilation will
  fail because the underlying resource is not present.