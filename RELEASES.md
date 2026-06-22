# Releases

## SP-001 — Foundation Layer — Namespace, ConfigMap, k3d Cluster

**Date**: 2026-06-22

### Summary

Delivers the three foundational infrastructure artifacts that every Eve Realm component depends on:

- `k8s/namespace.yaml` — the `eve-realm` Kubernetes namespace with `app.kubernetes.io/part-of: eve-realm` label
- `k8s/configmap.yaml` — the `eve-realm-config` shared ConfigMap with 14 environment variables for local k3d development
- `scripts/k3d-cluster.sh` — k3d cluster lifecycle script with 5 subcommands (create, delete, start, stop, status)

### Entities

REQ-001, REQ-002, REQ-003, SC-001, SC-002, SC-003, SC-004, SC-005, SC-006, SC-007, SC-008, SC-009, SC-00A, SC-00B

## SP-002 — Makefile and Versioning

**Date**: 2026-06-22

### Summary

Completes the Makefile tooling for the eve-realm-infra repository:

- `VERSION` — created at repository root with initial value `0.1.0`
- `make bump-patch`, `make bump-minor`, `make bump-major` — semantic version increment targets using awk-based version arithmetic
- `make deploy` — extended to conditionally apply service directories (`k8s/nats/`, `k8s/redis/`) after namespace and configmap, with directory existence guards
- `make undeploy` — deletes service manifests with `--ignore-not-found`, preserving namespace and configmap
- `make undeploy-local` — deletes the entire `eve-realm` namespace (nuclear reset)
- `make k3d-status` — shows pods, services, and recent events in the `eve-realm` namespace via direct kubectl commands
- SC-012 (Cluster Targets Delegate to k3d Script) was pre-satisfied — no implementation changes required

### Entities

REQ-004, SC-00C, SC-00D, SC-00E, SC-00F, SC-010, SC-011, SC-012, SC-013
