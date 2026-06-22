---
content_hash: 41e2efef67fd32eef12d61b5cfe4f6f0200e5b079c248b120a507d1fca9660d5
created: "2026-06-22"
id: SC-005
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
    - dns
title: ConfigMap Service URLs Follow K8s DNS Pattern
type: happy-path
updated: "2026-06-22"
---

# SC-005: ConfigMap Service URLs Follow K8s DNS Pattern

## Preconditions

- The `k8s/configmap.yaml` manifest is available for inspection

## Steps

1. Extract the values of `EVE_REALM_NATS_URL`, `EVE_REALM_NATS_WS_URL`, and `EVE_REALM_REDIS_URL` from the ConfigMap manifest

## Expected Result

- Each internal service URL follows the pattern `<protocol>://<service-name>.eve-realm.svc.cluster.local:<port>`:
  - `EVE_REALM_NATS_URL`: `nats://eve-realm-nats.eve-realm.svc.cluster.local:4222`
  - `EVE_REALM_NATS_WS_URL`: `ws://eve-realm-nats.eve-realm.svc.cluster.local:9222`
  - `EVE_REALM_REDIS_URL`: `redis://eve-realm-redis.eve-realm.svc.cluster.local:6379`
- External service URLs (DSN, Neo4j) use `host.docker.internal` for host-machine access from within k3d
