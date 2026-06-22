---
content_hash: 037d1fbcd721b3a586b5bd9924752dc97418bd25e7bdbc300afae3402e0953d1
created: "2026-06-22"
id: SC-011
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - deploy
title: Undeploy-Local Deletes Entire Namespace
type: happy-path
updated: "2026-06-22"
---

# SC-011: Undeploy-Local Deletes Entire Namespace

## Covers
- REQ-004 AC 7: `make undeploy-local` deletes the entire `eve-realm` namespace with `--ignore-not-found`

## Preconditions
- Infra fully deployed (namespace, configmap, services)

## Steps
1. Run `make undeploy-local`

## Expected Result
- Entire `eve-realm` namespace deleted (cascade deletes all resources within)
- `--ignore-not-found` used (no error if namespace absent)
