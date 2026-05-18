# Progress: DscConfig.AADConnect

_Last updated: 2026-05-18_

## Current State

- Module is shipped and in maintenance mode.
- Two composite resources are stable: `AADSyncRules` and
  `AADConnectDirectoryExtensionAttributes`.
- Documentation set is complete: `README.md`, `docs/AADSyncRules.md`,
  `docs/AADConnectDirectoryExtensionAttributes.md`, and five example
  scripts under `examples/`.
- Build pipeline: Sampler + InvokeBuild + Pester 5, GitVersion-driven.
- Last release artifacts present under `output/` (v0.2.0-fix0001).

## What's Left

- None planned. Reactive maintenance only (dependency bumps, community PRs,
  bug fixes if reported).

## Recent Log

- 2026-05-18 — Re-enabled the `AADSyncRuleCounts` compile test now that the
  locally-built `AADConnectDsc 0.6.0` (with `AADSyncRuleCount`) is staged
  under `output/RequiredModules/AADConnectDsc/0.6.0/`. Full build in a fresh
  pwsh session passes 8/8 tests. Documented the in-process DSC parser
  keyword-cache pitfall in `activeContext.md`.
- 2026-05-18 — Fixed the broken build: added missing `DscResourcesToExport`
  to the module manifest (root cause: `Get-DscResource -Module` returned 0,
  so the per-resource compile tests never ran and the Final tests failed),
  and skipped the `AADSyncRuleCounts` compile test until `AADConnectDsc`
  publishes `AADSyncRuleCount`. Full default build now exits 0.
- 2026-05-18 — Added `AADSyncRuleCounts` composite resource on branch
  `ai/add-aadsyncrulecounts` wrapping the new report-only `AADSyncRuleCount`
  resource from `AADConnectDsc` (`feature/AadsyncrulecountResource`).
- 2026-05-18 — Memory Bank refreshed: folder renamed to `.memory-bank/`,
  files trimmed to new agent-spec caps, `promptHistory.md` added.
- 2025-10 — Documentation pass: README cross-links to `docs/`, examples
  README added, memory bank populated.
- Earlier history summarized; pre-2025-10 milestone detail removed per the
  90-day retention rule.

## Decision Evolution

- **Composite resource pattern (vs class-based)** — retained. Rationale in
  `systemPatterns.md`.
- **Minimal validation in composite, delegate to AADConnectDsc** — retained.
- **Default `Ensure = ''Present''`** — retained.
