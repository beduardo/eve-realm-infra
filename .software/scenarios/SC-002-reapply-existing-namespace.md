---
content_hash: 67678eea63b5247869c732bf18145b797e316fa6aa2f6a374869d327ef9b05bf
created: "2026-06-22"
id: SC-002
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
    - idempotency
title: Reapply Existing Namespace
type: happy-path
updated: "2026-06-22"
---

# SC-002: Reapply Existing Namespace

## Preconditions

- A running k3d cluster with the `eve-realm` namespace already created

## Steps

1. Run `kubectl apply -f k8s/namespace.yaml`

## Expected Result

- Command exits with code 0 and outputs "namespace/eve-realm unchanged"
- The namespace retains its original labels and metadata without modification
