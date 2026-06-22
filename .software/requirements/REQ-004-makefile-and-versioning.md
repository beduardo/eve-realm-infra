---
content_hash: d4a99fbf5fcb9598d2a2deb02025fd644216ce21ab24a0aa74793d7a7fd56c58
created: "2026-06-22"
id: REQ-004
priority: high
related_adrs: []
related_changes: []
related_scenarios:
    - SC-00C
    - SC-00D
    - SC-00E
    - SC-00F
    - SC-010
    - SC-011
    - SC-012
    - SC-013
related_testcases: []
related_userstories: []
source: manual
status: active
tags:
    - makefile
    - versioning
    - deploy
    - foundation
title: Makefile and Versioning
updated: "2026-06-22"
---

# REQ-004: Makefile and Versioning

## Description

The infra provides a Makefile with semantic versioning targets and deployment automation.
A `VERSION` file at the repository root stores the current version. Bump targets increment
the version following semver conventions. Deploy targets apply all infra manifests to the
local k3d cluster. Cluster lifecycle targets wrap the k3d management script. Together,
these provide the operational surface for developing and testing the infra.

## Acceptance Criteria

1. A `VERSION` file at the repository root contains the current semantic version (e.g., `0.1.0`)
2. `make bump-patch` increments the patch version (0.1.0 → 0.1.1)
3. `make bump-minor` increments the minor version and resets patch (0.1.1 → 0.2.0)
4. `make bump-major` increments the major version and resets minor and patch (0.2.0 → 1.0.0)
5. `make deploy` applies all infra manifests in dependency order: namespace first, then configmap, then service directories (NATS, Redis when available)
6. `make undeploy` deletes infra service manifests (NATS, Redis) with `--ignore-not-found` but does NOT delete the namespace
7. `make undeploy-local` deletes the entire `eve-realm` namespace with `--ignore-not-found` (nuclear reset)
8. `make cluster-create` calls `scripts/k3d-cluster.sh create`
9. `make cluster-delete` calls `scripts/k3d-cluster.sh delete`
10. `make cluster-start` calls `scripts/k3d-cluster.sh start`
11. `make cluster-stop` calls `scripts/k3d-cluster.sh stop`
12. `make cluster-status` calls `scripts/k3d-cluster.sh status`
13. `make k3d-status` shows pods, services, and recent events in the `eve-realm` namespace

## Target Paths

- `VERSION`
- `Makefile`
