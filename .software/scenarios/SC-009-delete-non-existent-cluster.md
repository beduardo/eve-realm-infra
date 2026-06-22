---
content_hash: 954b9acea29353d2409034ecba4d223e037ea0e1ccea24518a17d55e06b1d5d0
created: "2026-06-22"
id: SC-009
related_changes: []
related_reqs:
    - REQ-003
related_testcases: []
source: manual
status: implemented
tags:
    - k3d
    - cluster
    - scripts
    - idempotency
title: Delete Non-Existent Cluster
type: happy-path
updated: "2026-06-22"
---

# SC-009: Delete Non-Existent Cluster

## Preconditions

- No k3d cluster named `eve-realm` exists
- No k3d registry named `eve-realm-registry.localhost` exists

## Steps

1. Run `scripts/k3d-cluster.sh delete`

## Expected Result

- The script completes without error (exit code 0)
- Both `k3d cluster delete` and `k3d registry delete` fail silently via `|| true`
