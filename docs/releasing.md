# Releasing Fluent Zenith

## Normal release

1. Merge a pull request with one release category and one SemVer label.
2. Review and merge the Release Please pull request. It updates `wally.toml`, `Src/init.luau`, and `CHANGELOG.md` together.
3. The release workflow builds the exact tag once, validates checksums and provenance, creates a draft release, and promotes it from the protected `production` environment.
4. Confirm the stable download contains the expected embedded version before announcing it.

Never upload a locally rebuilt asset to repair a release. Re-run the publish job only after the retained artifact's checksums pass.

## Prereleases and failures

Use `vX.Y.Z-rc.N` for release candidates; stable `latest` is not moved until stable validation passes. A failed publish remains a draft or is deleted before retrying. Record the incident, impact, remediation, and prevention work.

## Rollback

Never move an existing tag. For code defects, revert and ship a new patch. If the current stable release is unusable, use the protected rollback workflow to promote the prior known-good release as `latest`, then prepare the corrective patch. The workflow records the source release, operator, reason, and target release in the job summary.
