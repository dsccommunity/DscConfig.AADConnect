# Active Context: DscConfig.AADConnect

_Last updated: 2026-05-18_

## Current Focus

Adding a new composite resource `AADSyncRuleCounts` that wraps the report-only
`AADSyncRuleCount` DSC resource introduced in the `feature/AadsyncrulecountResource`
branch of the `AADConnectDsc` repository (working copy at `d:\a`).

The composite mirrors the existing `AADSyncRules` /
`AADConnectDirectoryExtensionAttributes` schema-module pattern. It accepts an
array of hashtables (`ConnectorName`, `RuleCount`) and emits one
`AADSyncRuleCount` instance per item, mapping empty / `'*'` connector names to
the literal token `AllConnectors` so execution names stay unique.

Files added/changed on branch `ai/add-aadsyncrulecounts`:

- `source/DSCResources/AADSyncRuleCounts/AADSyncRuleCounts.psd1`
- `source/DSCResources/AADSyncRuleCounts/AADSyncRuleCounts.schema.psm1`
- `tests/Unit/DSCResources/Assets/Config/AADSyncRuleCounts.yml`
- `docs/AADSyncRuleCounts.md`
- `examples/6-AADSyncRuleCounts.ps1`
- `examples/README.md`, `README.md`, `CHANGELOG.md` updates
- This memory bank refresh

## Open Decisions

- Discovered (and fixed) a pre-existing bug: the module manifest was missing
  `DscResourcesToExport`, which made `Get-DscResource -Module` return zero
  composite resources in PowerShell 7. The build had been silently broken.
- The `AADSyncRuleCounts` compile test is enabled. It requires an
  `AADConnectDsc` build that exposes `AADSyncRuleCount` (v0.6.0 of
  `AADConnectDsc` or later). Local build uses the 0.6.0 build copied
  from `d:\a` into `output/RequiredModules/AADConnectDsc/0.6.0/`. CI will
  pick it up once `RequiredModules.psd1` (already `latest`) resolves to a
  published version that ships `AADSyncRuleCount`.
- **In-process DSC parser caching**: `Get-DscResource -Module` and the DSC
  keyword table are cached per process. Re-running the build in a long-lived
  pwsh session that previously loaded an older `AADConnectDsc` will leave
  stale keywords and make the new resource appear missing. Always run the
  build in a fresh process (or `pwsh -NoProfile`) when changing the
  underlying `AADConnectDsc` version.

## Next Steps (when work resumes)

1. Wait for the `AADConnectDsc` PR (`feature/AadsyncrulecountResource`) to be
   merged and a new version published, so CI can resolve `AADConnectDsc` from
   the gallery instead of relying on the local 0.6.0 copy.
2. Cut a release with the `Unreleased` entry promoted to a numbered version.

## Non-Goals

- No additional composite resources planned.
- No restructuring of the build pipeline.