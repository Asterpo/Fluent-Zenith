# Changelog

All notable changes are documented here. Entries are generated from normalized pull-request metadata by Release Please.

## [1.2.2] - 2026-07-24

### Fixed

- Pass the StyLua line-ending policy directly to CI so the release gate is platform-independent.

## [1.2.1] - 2026-07-24

### Fixed

- Made StyLua line endings explicit so Windows CI and repository checkouts apply the same formatting rules.

## [1.2.0] - 2026-07-24

### Added

- Public Luau type declarations, verified Studio and release-loader installation guidance, and API documentation.
- Quality gates for formatting, linting, strict-source coverage, tests, mock UNC behavior, and release smoke checks.
- Release Please, PR release-note metadata validation, version synchronization, protected publishing, provenance, stable-download verification, and rollback automation.

### Internal engineering

- Release notes and this changelog now share categorized pull-request metadata.
