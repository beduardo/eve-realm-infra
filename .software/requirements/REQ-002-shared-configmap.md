---
content_hash: 412c068cd70126613cf1b82de0f173e4fae2c0a4c361de2a7d64bc4761796e2f
created: "2026-06-22"
id: REQ-002
priority: high
related_adrs: []
related_changes: []
related_scenarios:
    - SC-003
    - SC-004
    - SC-005
related_testcases: []
related_userstories: []
source: manual
status: implemented
tags:
    - configmap
    - foundation
    - k8s
    - environment
title: Shared ConfigMap
updated: "2026-06-22"
---

# REQ-002: Shared ConfigMap

## Description

The infra provides a shared ConfigMap (`eve-realm-config`) in the `eve-realm` namespace
that centralises all environment variables consumed by the hub and plugins. Every deployment
in the platform references this ConfigMap via `envFrom: configMapRef`, making it the single
source of environment truth for database connections, authentication, messaging, and caching.

## Acceptance Criteria

1. The manifest defines a `ConfigMap` with `metadata.name: eve-realm-config` in namespace `eve-realm`
2. The ConfigMap includes the label `app.kubernetes.io/part-of: eve-realm`
3. The ConfigMap contains exactly these 14 keys with the specified values:

| Key | Value |
|-----|-------|
| `EVE_REALM_DSN` | `postgres://eve-realm:eve-realm@host.docker.internal:5432/eve-realm?sslmode=disable` |
| `EVE_REALM_CONTROL_DSN` | `postgres://eve-realm:eve-realm@host.docker.internal:5432/eve-realm_control_plane?sslmode=disable` |
| `EVE_REALM_LOG_LEVEL` | `debug` |
| `EVE_REALM_AUTH_DOMAIN` | `dev-twmpbn8pib668naq.us.auth0.com` |
| `EVE_REALM_AUTH_AUDIENCE` | `https://api.eve-realm.dev` |
| `EVE_REALM_AUTH_CLIENT_ID_CLI` | `Z1WxIkqdujlNd7LbgN808SFK9You2fN7` |
| `EVE_REALM_AUTH_CLIENT_ID_WEB` | `bAQpA616A9dXfq5JzV6OXeSeILcNjvvi` |
| `EVE_REALM_SERVER_URL` | `` (empty string) |
| `EVE_REALM_NATS_URL` | `nats://eve-realm-nats.eve-realm.svc.cluster.local:4222` |
| `EVE_REALM_NATS_WS_URL` | `ws://eve-realm-nats.eve-realm.svc.cluster.local:9222` |
| `EVE_REALM_NATS_PASSWORD` | `eve-realm-nats` |
| `EVE_REALM_NATS_BROWSER_TOKEN` | `eve-realm-browser` |
| `EVE_REALM_REDIS_URL` | `redis://eve-realm-redis.eve-realm.svc.cluster.local:6379` |
| `EVE_REALM_NEO4J_URI` | `bolt://neo4j:eve-realm@host.docker.internal:7687/eve-realm` |

4. Internal service URLs follow the K8s DNS pattern: `<protocol>://<service-name>.<namespace>.svc.cluster.local:<port>`
5. Credentials are stored in plaintext — acceptable for k3d local development
6. No other keys, labels, or annotations are defined beyond the specified set

## Target Path

`k8s/configmap.yaml`
