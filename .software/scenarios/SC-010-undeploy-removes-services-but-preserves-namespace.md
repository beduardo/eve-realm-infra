---
content_hash: fe56d9eabce4675111453049dbdef34a75e13ac3cc7c33adfacc22ee6c3d16b7
created: "2026-06-22"
id: SC-010
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - deploy
title: Undeploy Removes Services but Preserves Namespace
type: happy-path
updated: "2026-06-22"
---

# SC-010: Undeploy Removes Services but Preserves Namespace

## Covers
- REQ-004 AC 6: `make undeploy` deletes infra service manifests with `--ignore-not-found` but does NOT delete the namespace

## Preconditions
- Infra fully deployed (namespace, configmap, services)

## Steps
1. Run `make undeploy`

## Expected Result
- Service manifests (NATS, Redis) deleted
- `--ignore-not-found` used (no error if resources absent)
- Namespace `eve-realm` still exists
- ConfigMap still exists (only services removed)
