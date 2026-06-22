---
content_hash: 3de6ca37b324fef6c68ae79b3b89df2afc6ce4a814d7129c20ba4dfa7a3dc0a3
created: "2026-06-22"
id: SC-00A
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
title: Start and Stop Preserve Cluster State
type: happy-path
updated: "2026-06-22"
---

# SC-00A: Start and Stop Preserve Cluster State

## Preconditions

- A k3d cluster named `eve-realm` exists and is running
- The `eve-realm` namespace and infra services are deployed

## Steps

1. Run `scripts/k3d-cluster.sh stop`
2. Verify cluster is stopped via `k3d cluster list`
3. Run `scripts/k3d-cluster.sh start`
4. Verify cluster is running via `k3d cluster list`

## Expected Result

- After stop: cluster shows as stopped, exit code 0
- After start: cluster shows as running, exit code 0
- Previously deployed resources (namespace, services) are preserved after the start/stop cycle
