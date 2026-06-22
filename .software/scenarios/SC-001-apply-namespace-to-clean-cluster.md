---
content_hash: a541da907ed33c51fea37fe550c37472cb11b9f672e8bd4e2583518096b22c55
created: "2026-06-22"
id: SC-001
related_changes: []
related_reqs:
    - REQ-001
related_testcases: []
source: manual
status: implemented
tags:
    - namespace
    - foundation
    - k8s
title: Apply Namespace to Clean Cluster
type: happy-path
updated: "2026-06-22"
---

# SC-001: Apply Namespace to Clean Cluster

## Preconditions

- A running k3d cluster with no `eve-realm` namespace

## Steps

1. Run `kubectl apply -f k8s/namespace.yaml`

## Expected Result

- Command exits with code 0 and outputs "namespace/eve-realm created"
- `kubectl get namespace eve-realm` returns the namespace with status Active
- `kubectl get namespace eve-realm --show-labels` shows `app.kubernetes.io/part-of=eve-realm`
- No other labels or annotations are present on the namespace
