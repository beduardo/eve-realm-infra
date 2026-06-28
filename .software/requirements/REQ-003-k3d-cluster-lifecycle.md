---
content_hash: 59fb7bcd11e6c9cda1dd7d041c393948b3c9f9e76af5a1ad56acfedfa23fc4be
created: "2026-06-22"
id: REQ-003
priority: high
related_adrs: []
related_changes: []
related_scenarios:
    - SC-006
    - SC-007
    - SC-008
    - SC-009
    - SC-00A
    - SC-00B
related_testcases: []
related_userstories: []
source: manual
status: implemented
tags:
    - k3d
    - cluster
    - scripts
    - foundation
title: k3d Cluster Lifecycle
updated: "2026-06-22"
---

# REQ-003: k3d Cluster Lifecycle

## Description

The infra provides a bash script (`scripts/k3d-cluster.sh`) that manages the full lifecycle
of the local k3d development cluster, including a Docker registry for container images. The
script supports creating, destroying, starting, stopping, and inspecting the cluster with
idempotent operations and clear error handling.

## Acceptance Criteria

1. The script is located at `scripts/k3d-cluster.sh`, uses `bash` with `set -euo pipefail`
2. Supports 5 commands: `create`, `delete`, `start`, `stop`, `status`
3. Configuration constants:
   - `CLUSTER_NAME=eve-realm`
   - `REGISTRY_NAME=eve-realm-registry.localhost`
   - `REGISTRY_PORT=5100`
   - `API_PORT=6550`
   - `HTTP_PORT=30000`
   - `GRPC_PORT=30051`
4. `create` command:
   - Creates the registry via `k3d registry create` with port 5100 (idempotent — ignores already-exists error via `|| true`)
   - Creates the cluster with `--registry-use k3d-eve-realm-registry.localhost:5100`, `--api-port 6550`, `--port 30000:30000@server:0`, `--port 30051:30051@server:0`, `--k3s-arg "--disable=traefik@server:0"`, `--wait`
   - Exits with error if the cluster already exists (guard check before creation)
   - Prints cluster info, registry address, NodePort addresses (HTTP and gRPC), and next steps on success
5. `delete` command: removes cluster and registry, both idempotent via `|| true`
6. `start`/`stop` commands: resume/pause the cluster preserving state
7. `status` command: lists k3d clusters, registries, and — if the kubectl context matches the cluster — pods and services in the `eve-realm` namespace
8. Traefik is disabled — local access is via NodePort 30000 (HTTP) and 30051 (gRPC) directly
9. Invalid or missing command input displays usage and exits with code 1

## Target Path

`scripts/k3d-cluster.sh`
