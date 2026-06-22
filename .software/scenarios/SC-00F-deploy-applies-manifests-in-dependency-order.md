---
content_hash: c5392fe6fa088a5032d279b133c8c49e988c905d6c25b2cfffe8c6141b035758
created: "2026-06-22"
id: SC-00F
related_changes: []
related_reqs:
    - REQ-004
related_testcases: []
source: manual
status: validated
tags:
    - makefile
    - deploy
title: Deploy Applies Manifests in Dependency Order
type: happy-path
updated: "2026-06-22"
---

# SC-00F: Deploy Applies Manifests in Dependency Order

## Covers
- REQ-004 AC 5: `make deploy` applies all infra manifests in dependency order — namespace first, then configmap, then service directories

## Preconditions
- k3d cluster running
- Infra manifests present in `k8s/`

## Steps
1. Run `make deploy`

## Expected Result
- Namespace `eve-realm` created/confirmed first
- Shared ConfigMap applied after namespace
- Service directories (NATS, Redis when present) applied after ConfigMap
- All resources report as created or unchanged
