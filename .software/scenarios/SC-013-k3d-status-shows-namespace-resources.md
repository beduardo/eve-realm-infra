---
content_hash: 0ff5e92131c285f13e3503a7207392940bdcca82a2a541c9f72af64a72cd61f5
created: "2026-06-22"
id: SC-013
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - cluster
title: k3d-Status Shows Namespace Resources
type: happy-path
updated: "2026-06-22"
---

# SC-013: k3d-Status Shows Namespace Resources

## Covers
- REQ-004 AC 13: `make k3d-status` shows pods, services, and recent events in the `eve-realm` namespace

## Preconditions
- k3d cluster running
- Infra deployed (namespace, configmap, at minimum)

## Steps
1. Run `make k3d-status`

## Expected Result
- Output includes pod listing for `eve-realm` namespace
- Output includes service listing for `eve-realm` namespace
- Output includes recent events for `eve-realm` namespace
