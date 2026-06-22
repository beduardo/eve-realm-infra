---
content_hash: 529dc9568eb588f2fad47d9068ee10fed3fee3bd7ab303487dbb53e7625855cb
created: "2026-06-22"
id: SC-00C
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - versioning
title: Bump Patch Version
type: happy-path
updated: "2026-06-22"
---

# SC-00C: Bump Patch Version

## Covers
- REQ-004 AC 1: VERSION file at repo root contains current semantic version
- REQ-004 AC 2: `make bump-patch` increments patch version

## Preconditions
- Repository root contains `VERSION` file with content `0.1.0`

## Steps
1. Run `make bump-patch`

## Expected Result
- `VERSION` file contains `0.1.1`
- No other files modified
