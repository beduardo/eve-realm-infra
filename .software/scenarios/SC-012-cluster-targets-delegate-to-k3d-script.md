---
content_hash: ca9416a8f1d79cd0660c93f731527f92a12193913aea985b7cea63557ce6048b
created: "2026-06-22"
id: SC-012
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - cluster
title: Cluster Targets Delegate to k3d Script
type: happy-path
updated: "2026-06-22"
---

# SC-012: Cluster Targets Delegate to k3d Script

## Covers
- REQ-004 AC 8: `make cluster-create` calls `scripts/k3d-cluster.sh create`
- REQ-004 AC 9: `make cluster-delete` calls `scripts/k3d-cluster.sh delete`
- REQ-004 AC 10: `make cluster-start` calls `scripts/k3d-cluster.sh start`
- REQ-004 AC 11: `make cluster-stop` calls `scripts/k3d-cluster.sh stop`
- REQ-004 AC 12: `make cluster-status` calls `scripts/k3d-cluster.sh status`

## Preconditions
- `scripts/k3d-cluster.sh` exists and is executable

## Steps
1. Inspect Makefile targets `cluster-create`, `cluster-delete`, `cluster-start`, `cluster-stop`, `cluster-status`

## Expected Result
- Each target's recipe is a single call to `scripts/k3d-cluster.sh <verb>` with the matching verb
- No additional logic in the Makefile targets beyond the script delegation
