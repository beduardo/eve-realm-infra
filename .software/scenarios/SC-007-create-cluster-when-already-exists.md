---
content_hash: 79376aaf7567aa5ea88d4ad32b2fec7ab4dd45e1a657578d18e38a75e12ce214
created: "2026-06-22"
id: SC-007
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
    - error
title: Create Cluster When Already Exists
type: happy-path
updated: "2026-06-22"
---

# SC-007: Create Cluster When Already Exists

## Preconditions

- A k3d cluster named `eve-realm` already exists

## Steps

1. Run `scripts/k3d-cluster.sh create`

## Expected Result

- The script exits with code 1
- An error message indicates the cluster already exists and suggests using `start`
- No new cluster or registry is created
