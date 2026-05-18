# Prompt History

A one-line entry per substantive Copilot turn. Format:
`YYYY-MM-DD HH:mm UTC | agent | one-line intent`

2026-05-18 09:53 UTC | software-engineer | Add AADSyncRuleCounts composite wrapping new AADSyncRuleCount resource from AADConnectDsc
2026-05-18 10:06 UTC | software-engineer | Fix broken build: add DscResourcesToExport to manifest; skip AADSyncRuleCounts test until AADConnectDsc ships AADSyncRuleCount
2026-05-18 10:30 UTC | software-engineer | Re-enable AADSyncRuleCounts test against local AADConnectDsc 0.6.0; root cause of false failures was per-process DSC keyword caching
