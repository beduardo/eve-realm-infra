---
content_hash: 261d264929dad41d916fb597febbe7587c572d9612d725a97dec44721ef5add7
created: "2026-06-22"
id: SC-008
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
title: Delete Existing Cluster
type: happy-path
updated: "2026-06-22"
---

# SC-008: Delete Existing Cluster

## Preconditions

- A k3d cluster named `eve-realm` exists
- A k3d registry named `eve-realm-registry.localhost` exists

## Steps

1. Run `scripts/k3d-cluster.sh delete`

## Expected Result

- The cluster `eve-realm` is deleted
- The registry `k3d-eve-realm-registry.localhost` is deleted
- Exit code is 0
