---
content_hash: 15ec0d85b8a80592861794b418c049ed067ee4f7b669824a2492f840153b3e0f
created: "2026-06-22"
id: SC-00E
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - versioning
title: Bump Major Version Resets Minor and Patch
type: happy-path
updated: "2026-06-22"
---

# SC-00E: Bump Major Version Resets Minor and Patch

## Covers
- REQ-004 AC 4: `make bump-major` increments major version and resets minor and patch

## Preconditions
- Repository root contains `VERSION` file with content `0.2.0`

## Steps
1. Run `make bump-major`

## Expected Result
- `VERSION` file contains `1.0.0`
- Minor and patch components reset to 0
