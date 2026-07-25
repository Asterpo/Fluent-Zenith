# Fluent Zenith Product Roadmap

- **Roadmap date:** July 24, 2026
- **Current package version:** 1.2.3
- **Planning horizon:** Seven planned releases over approximately 20 weeks
- **Target environments:** Roblox Studio, PlayerGui, Roblox plugins, and compatible UNC runtimes through defensive adapters

## Product direction

Fluent Zenith will become a small-core, themeable Luau GUI toolkit with predictable lifecycle management, strong Studio safety, responsive input support, and a fully automated release process. Every planned version is independently shippable, has a focused outcome, and is accompanied by clear release criteria.

## Guiding principles

- **Studio safety first:** Standard Roblox Studio and PlayerGui use must work without external runtime globals.
- **Defensive compatibility:** Optional environment APIs are guarded with `pcall` and safe fallbacks.
- **Explicit ownership:** Instances, signals, connections, and animations belong to a scope and are safe to destroy repeatedly.
- **Stable public APIs:** Types, configuration, and migration guidance are released with the code that requires them.
- **Build once, publish once:** Releases promote the exact artifact that passed validation; publishing never rebuilds it.
- **Plain-language transparency:** Every user-facing change has an understandable release note and clear migration instruction when needed.

## Version release roadmap

### v1.0.2 - Stabilization and release workflow repair

**Timeline:** Week 1

**Goal:** Establish a safe baseline and make the existing GitHub Release workflow dependable before broader modernization begins.

**Planned deliverables:**

- Record baseline require-time, element-creation, memory, and bundle-size metrics.
- Align `Example.client.luau` and `place.project.json` mount paths.
- Add `callSafely` guards for filesystem, host-container, and reference-cloning APIs.
- Add regression coverage for mobile minimize sizing, numeric input validation, and nil-title updates.
- Track `wally.lock` for reproducible dependency resolution.
- Repair manual and tag release triggers; serialize release jobs; add concurrency protection, least-privilege permissions, asset assertions, and draft-first publication.

**Release criteria:** Studio examples load without mount errors; missing optional APIs warn rather than crash; runtime, package, and tag versions agree on `v1.0.2`; and a dry run either creates one verified draft release with both assets or publishes nothing.

### v1.1.0 - Lifecycle foundation and reproducible builds (complete)

**Timeline:** Weeks 2-4

**Goal:** Make runtime ownership explicit and ensure pull requests and releases use the same repeatable build path.

**Planned deliverables:**

- Introduce `Scope` lifecycle management for instances, signals, connections, motors, and child scopes.
- Add `RobloxHostAdapter`, `DeltaHostAdapter`, `UNCFilePersistenceAdapter`, and `ClonerefResolver`.
- Add central `App.Flags`, developer `overrideSetting()`, and idempotent `Destroy()` support for windows, tabs, and elements.
- Extract a reusable CI build workflow with RoKit and Wally caches, size budgets, artifact assertions, smoke tests, immutable artifact retention, `SHA256SUMS.txt`, and `release-manifest.json`.

**Release criteria:** Re-execution and `App:Destroy()` leave no residual instances or active connections; persistence falls back to memory when file APIs are absent; and the release checksum matches the reviewed CI artifact exactly.

### v1.2.0 - Quality gates and automated releases (complete)

**Timeline:** Weeks 5-7

**Goal:** Turn validated merged changes into reviewable, documented, recoverable releases.

**Planned deliverables:**

- Require StyLua, Selene, strict Luau analysis, Lune tests, mock UNC tests, and release smoke tests in CI.
- Publish `PublicTypes.luau`, verified loader examples, Studio installation guidance, and API documentation.
- Configure Release Please for semantic versioning and release pull requests.
- Enforce Conventional Commit-compatible squash titles and structured pull-request release-note fields.
- Add version synchronization checks for `wally.toml`, `Src/init.luau`, tags, and release titles.
- Generate `CHANGELOG.md` and GitHub Release notes from the same normalized pull-request data.
- Add protected release environments, artifact provenance, stable-download tests, notifications, a release runbook, and an audited rollback workflow.

**Release criteria:** Every pull request passes required checks; merged changes produce a release pull request with the correct SemVer bump and categorized notes; and a release candidate can be promoted or rolled back without a local build or manual asset upload.

### v1.3.0 - Adaptive input and user feedback

**Timeline:** Weeks 8-10

**Goal:** Provide consistent touch, mouse, keyboard, gamepad, and modal interactions.

**Planned deliverables:**

- Implement `InputRouter` and `FocusManager`.
- Expand interactive targets to 44 x 44 pt minimum where applicable.
- Add touch drag resistance and virtual-keyboard window adjustment.
- Add `App:Prompt()` for system notices and advisories.
- Add a global `LibraryOpenKeybind` for deterministic window minimize and restore.

**Release criteria:** Mobile controls do not conflict with scrolling or obscure focus; prompts trap modal focus correctly; and global window toggling behaves consistently across supported input methods.

### v1.4.0 - Performance and dynamic assets

**Timeline:** Weeks 11-13

**Goal:** Reduce startup payload while keeping large collections and optional assets responsive.

**Planned deliverables:**

- Virtualize `Dropdown` and `ListBox` rendering.
- Split icons into a minimal core set and optional Lucide and Phosphor packs.
- Add `HTTPAssetProvider` with request timeouts and a local manifest cache.
- Batch theme changes into single-frame updates.

**Release criteria:** The minified core loader is under 100KB; 10,000-item dropdowns maintain the target frame rate; and optional icons load from HTTP on first use and from cache thereafter.

### v1.5.0 - Component expansion and developer tooling

**Timeline:** Weeks 14-17

**Goal:** Expand the everyday widget set and make the library easier to extend safely.

**Planned deliverables:**

- Add `Label`, `Heading`, `Divider`, `Tooltip`, `ProgressBar`, `RadioGroup`, `SegmentedControl`, and `NumberInput`.
- Add responsive `Row`, `Column`, and `Grid` containers.
- Add `VisibleWhen` and `EnabledWhen` dependency containers.
- Add a `RegisterElement` extension API using public tokens and scopes.
- Add schema-driven form generation with persistence and validation.

**Release criteria:** Third-party controls can be registered and destroyed through public APIs, and generated forms preserve validation and saved configuration behavior.

### v2.0.0 - Multi-window ecosystem and production hardening

**Timeline:** Weeks 18-20

**Goal:** Ship the first major modernized release with migration support and production evidence across target environments.

**Planned deliverables:**

- Support multiple windows across one or more `App` contexts.
- Deliver Theme Lab with live editing, contrast validation, and JSON export.
- Complete beta testing in representative Studio and supported runtime projects.
- Publish stable assets, checksums, provenance, full release notes, and migration documentation.

**Release criteria:** v2.0.0 passes the automated pipeline, has reproducible checksummed artifacts, includes complete migration guidance, and has no unresolved release-blocking beta issues.

### Releases after v2.0.0

Future iterations may add virtualized tree views and data tables, context menus, command palettes, shortcut help, and native Roblox `StyleSheet` or `StyleLink` integration as platform support matures.

## Automated release management

### Release flow

```text
Pull request
  -> validate tests, metadata, labels, and release-note fields
  -> merge to main
  -> Release Please updates a version and changelog pull request
  -> merge release pull request
  -> create vMAJOR.MINOR.PATCH tag
  -> build and test the tagged commit once
  -> verify manifest, checksums, and download behavior
  -> publish GitHub Release
  -> optionally publish the same verified version to Wally
```

The pipeline stops on any failed gate. GitHub Releases are created as drafts and become public only after `Fluent.luau`, `Fluent.rbxm`, checksums, provenance, and smoke-test results are verified.

### Version policy

- Use Semantic Versioning with strict `vMAJOR.MINOR.PATCH` tags.
- Use Release Please as the primary versioning and release-pull-request tool.
- Use Conventional Commit-compatible squash titles: `feat` for minor changes, `fix` for patch changes, and explicit breaking-change markers for major changes.
- Use `vX.Y.Z-rc.N` tags for release candidates; stable `latest` remains unchanged until stable validation succeeds.
- Validate all version mirrors before publishing. Do not reuse an existing version tag.

### Build, promotion, and integrity

The reusable build workflow must check out the exact release commit, install the RoKit toolchain from `rokit.toml`, restore Wally dependencies from the lockfile, run quality checks, and produce the distribution files once. It then creates:

- `Fluent.luau` and `Fluent.rbxm`
- `SHA256SUMS.txt`
- `release-manifest.json` containing version, tag, commit SHA, tools, file sizes, and hashes
- An SPDX or CycloneDX SBOM where practical
- An immutable retained CI artifact and GitHub artifact provenance

The publish job downloads and verifies that artifact; it does not rebuild it. After publishing, it verifies `releases/latest/download/Fluent.luau` and its embedded version. Wally publication, if adopted, runs only after the GitHub Release succeeds and verifies installation in a clean project.

### Workflow ownership and safety

| Workflow | Responsibility |
| --- | --- |
| `ci.yml` | Lint, test, build, smoke test, and review artifact creation. |
| `pr-metadata.yml` | Validate titles, labels, SemVer impact, and release-note fields. |
| `release-please.yml` | Maintain the version and changelog release pull request. |
| `publish-release.yml` | Verify, attest, publish, and smoke-test release assets. |
| `rollback.yml` | Restore the previous known-good release or publish a hotfix with production approval. |

Pin third-party actions to commit SHAs, use the minimum job permissions, reserve write and OIDC permissions for publishing only, protect production environments, and add `CODEOWNERS` review for workflow, build, dependency, and release-script changes.

## Automatic changelogs

### Pull-request metadata

Each pull request must provide exactly one public category and a SemVer impact label. The template should require:

```text
Release note category: Added | Improved | Fixed | Security | Deprecated | Removed | Internal
User-facing summary: One sentence describing what changed and who benefits.
Why it matters: One or two sentences describing the prior problem and new behavior.
Migration or action required: Exact steps, or "None".
Compatibility: Studio | PlayerGui | Plugin | UNC | All
Breaking change: No | Yes, with upgrade instructions
```

`release-note:none` is allowed only for genuinely internal work and requires a stated reason.

### Generated note format

The changelog generator reads merged pull-request titles, labels, authors, links, and template fields since the prior tag. It produces the same normalized content for `CHANGELOG.md` and the GitHub Release body, grouped as:

1. Highlights
2. Added
3. Improved
4. Fixed
5. Security
6. Deprecated and removed
7. Compatibility and migration
8. Internal engineering

It excludes merge commits, duplicate entries, raw issue-closing boilerplate, internal-only changes, and dependency noise without user impact. CI rejects placeholder text, missing links, and breaking changes without migration guidance.

Use outcome-focused wording. For example:

```text
- Numeric inputs no longer crash during configuration reloads.
  Empty saved values now fall back safely instead of assigning nil to a TextBox.
  No migration is required. (#123)
```

Major releases may include a short human-edited Highlights paragraph; all detailed sections remain generated. Configure `.github/release.yml` as a category-map fallback for GitHub-generated release notes.

## Complementary practices

- Use automated path-based labels and ask reviewers to confirm them.
- Enable a merge queue after required checks are stable.
- Require CI, metadata validation, security scanning, and version consistency before merging.
- Enable Dependabot or Renovate, dependency review, secret scanning, and artifact attestations.
- Run a weekly non-publishing release rehearsal from `main`.
- Surface current version, latest CI result, and release status in the README and GitHub Environments.
- Notify maintainers of publication and failure with version, release link, commit SHA, highlights, and rollback link.
- Track lead time, release success rate, hotfixes, failed-gate causes, note-completeness rate, and rollback count.
- Start with a biweekly stable cadence plus on-demand security fixes; increase frequency only after the pipeline is consistently reliable.
- Maintain `docs/releasing.md` for normal releases, prereleases, failed publication, asset repair, hotfixes, and rollback.

## Rollback policy

Never move an existing tag to different code. For a code defect, revert the change and publish a new patch release. If the current stable release is unusable, restore the prior known-good release as `latest` while preparing the fix. If an asset upload alone failed, rerun the idempotent publish job after checksum verification; do not rebuild. Record cause, impact, remediation, and prevention work for every release incident.

## Definition of done

A version is complete when its scoped deliverables are implemented, typed where public, tested across relevant environments, documented, and included in clear generated release notes. The release must pass all quality gates, have matching runtime/package/tag/release versions, contain build-once checksummed artifacts traceable to the source commit, and provide migration guidance for every breaking change.

## Reference material

- Roblox Accessibility Guidelines
- Roblox Style Editor Documentation
- Rayfield UI Library documentation
- Luau UNC standard specification
- Fusion scope and lifecycle guidance
- Semantic Versioning, Conventional Commits, GitHub Actions, Release Please, and GitHub Release Notes documentation
