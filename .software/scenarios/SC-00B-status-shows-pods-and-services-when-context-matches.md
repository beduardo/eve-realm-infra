---
content_hash: 6b4804abf06624cc9aa869e29df83893f9c6cdc8a0c7815b26c153188f4546c9
created: "2026-06-22"
id: SC-00B
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
title: Status Shows Pods and Services When Context Matches
type: happy-path
updated: "2026-06-22"
---

# SC-00B: Status Shows Pods and Services When Context Matches

## Preconditions

- A k3d cluster named `eve-realm` is running
- The kubectl context is set to `k3d-eve-realm`
- The `eve-realm` namespace exists with at least one pod and service deployed

## Steps

1. Run `scripts/k3d-cluster.sh status`

## Expected Result

- Output includes a "Clusters" section listing the `eve-realm` cluster
- Output includes a "Registries" section listing the registry
- Output includes a "Pods" section showing pods in the `eve-realm` namespace
- Output includes a "Services" section showing services in the `eve-realm` namespace
- Exit code is 0
