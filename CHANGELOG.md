# Changelog for DscConfig.AADConnect

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New composite resource `AADSyncRuleCounts` that wraps the report-only
  `AADSyncRuleCount` DSC resource from `AADConnectDsc`. Accepts an array of
  hashtables (`ConnectorName`, `RuleCount`) and generates one underlying
  resource instance per item with a safe execution name. The empty / `'*'`
  connector value is mapped to the literal token `AllConnectors` so
  execution names stay unique across items.
  Requires `AADConnectDsc` with `AADSyncRuleCount` support.

### Changed

- Updated module dependencies in `RequiredModules.psd1`.
- Updated build scripts (`build.ps1`, `Resolve-Dependency.ps1`) to align
  with the latest version of Sampler.

### Fixed

- Added the missing `DscResourcesToExport` entry to
  `source/DscConfig.AADConnect.psd1` so `Get-DscResource -Module
  DscConfig.AADConnect` returns the composite resources. Without it, the
  `tests/Unit/DSCResources/DscResources.Tests.ps1` discovery returned zero
  resources, the per-resource compile tests were never generated, and the
  `Final tests` count comparison failed in PowerShell 7. The build is now
  green again.

## [0.2.0] - 2025-10-16

### Added

- Added documentation and examples.

### Changed

- Removed files of `DscBuildHelpers` and cleaned up `.gitignore`.
- Updated `RequiredModules.psd1`.
- Updated documentation.

### Fixed

- Formatting throughout the project.

## [0.1.1] - 2024-07-30

### Fixed

- The property 'Expression' in 'AADSyncRules.AttributeFlowMappings' cannot be $null.

## [0.1.0] - 2024-07-04

### Changed

- Initial Release.
- Created pipeline, changed initial version.
