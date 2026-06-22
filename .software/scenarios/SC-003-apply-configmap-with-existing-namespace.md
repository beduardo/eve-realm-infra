---
content_hash: 5021788c358943655d3caffdd38572a9f17a22e75b7e23e5033f425f21089684
created: "2026-06-22"
id: SC-003
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
title: Apply ConfigMap with Existing Namespace
type: happy-path
updated: "2026-06-22"
---

# SC-003: Apply ConfigMap with Existing Namespace

## Preconditions

- A running k3d cluster with the `eve-realm` namespace created

## Steps

1. Run `kubectl apply -f k8s/configmap.yaml`

## Expected Result

- Command exits with code 0 and outputs "configmap/eve-realm-config created"
- `kubectl get configmap eve-realm-config -n eve-realm` returns the ConfigMap
- The ConfigMap contains exactly 14 keys: `EVE_REALM_DSN`, `EVE_REALM_CONTROL_DSN`, `EVE_REALM_LOG_LEVEL`, `EVE_REALM_AUTH_DOMAIN`, `EVE_REALM_AUTH_AUDIENCE`, `EVE_REALM_AUTH_CLIENT_ID_CLI`, `EVE_REALM_AUTH_CLIENT_ID_WEB`, `EVE_REALM_SERVER_URL`, `EVE_REALM_NATS_URL`, `EVE_REALM_NATS_WS_URL`, `EVE_REALM_NATS_PASSWORD`, `EVE_REALM_NATS_BROWSER_TOKEN`, `EVE_REALM_REDIS_URL`, `EVE_REALM_NEO4J_URI`
- The ConfigMap has label `app.kubernetes.io/part-of: eve-realm`
