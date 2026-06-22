---
content_hash: b424fc4123c5f44c88c07b1b3f3be8b6729afc36d4728966e439e66d75a380ed
created: "2026-06-22"
id: SC-00D
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - versioning
title: Bump Minor Version Resets Patch
type: happy-path
updated: "2026-06-22"
---

# SC-00D: Bump Minor Version Resets Patch

## Covers
- REQ-004 AC 3: `make bump-minor` increments minor version and resets patch

## Preconditions
- Repository root contains `VERSION` file with content `0.1.1`

## Steps
1. Run `make bump-minor`

## Expected Result
- `VERSION` file contains `0.2.0`
- Patch component reset to 0
