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
