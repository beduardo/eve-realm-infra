---
content_hash: 9e04ed2232cc25701db1d346ad132c9bfc571ae383caf4202fb847314e7c941e
created: "2026-06-22"
id: SC-004
related_changes: []
related_reqs:
    - REQ-002
related_testcases: []
source: manual
status: implemented
tags:
    - configmap
    - foundation
    - k8s
    - idempotency
title: Reapply Existing ConfigMap
type: happy-path
updated: "2026-06-22"
---

# SC-004: Reapply Existing ConfigMap

## Preconditions

- A running k3d cluster with the `eve-realm` namespace and `eve-realm-config` ConfigMap already applied

## Steps

1. Run `kubectl apply -f k8s/configmap.yaml`

## Expected Result

- Command exits with code 0 and outputs "configmap/eve-realm-config unchanged"
- All 14 environment variable values remain identical to the original application
