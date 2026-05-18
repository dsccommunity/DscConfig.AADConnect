# Active Context: DscConfig.AADConnect

_Last updated: 2026-05-18_

## Current Focus

Project is in **maintenance mode**. No active feature work. The module has not
been touched for an extended period (last substantive work: October 2025
documentation pass).

This turn: refreshed the Memory Bank to align with the current agent
definition (folder renamed `memory-bank/` → `.memory-bank/`, added
`promptHistory.md`, trimmed `activeContext.md` and `progress.md` to the
prescribed caps).

## Open Decisions

None. No pending design questions.

## Next Steps (when work resumes)

1. Verify build still passes against current `AADConnectDsc` and `Sampler`
   versions (`./build.ps1 -AutoRestore -Tasks test`).
2. Refresh `RequiredModules.psd1` pins if dependencies have moved.
3. Review open issues / PRs on the DscCommunity repo before any change.
4. Reconsider whether `productContext.md` should be folded into
   `projectbrief.md` — it is no longer in the always-loaded set per the new
   agent spec and currently lives as an on-demand topic file.

## Non-Goals

- No new composite resources planned.
- No restructuring of the build pipeline.
- No migration off Sampler / ModuleBuilder.
