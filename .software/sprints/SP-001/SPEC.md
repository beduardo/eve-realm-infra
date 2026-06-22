# Sprint SP-001: Foundation Layer — Namespace, ConfigMap, k3d Cluster

**Created**: 2026-06-22
**Status**: Specified
**Entities**: 14

---

## Overview

This sprint establishes the foundational infrastructure layer that every other component of
the Eve Realm platform depends on. It delivers the Kubernetes namespace that scopes all
cluster resources (`k8s/namespace.yaml`), the shared ConfigMap that centralises environment
variables for all plugins and services (`k8s/configmap.yaml`), and the k3d cluster lifecycle
management script that controls the local development cluster (`scripts/k3d-cluster.sh`).
Without these three artifacts, no plugin can be deployed and no service can communicate —
making this sprint the prerequisite for all subsequent infra, hub, and plugin sprints.

## Entity Inventory

| ID | Type | Title | Partial | Scope Notes |
|----|------|-------|---------|-------------|
| REQ-001 | requirement | Eve Realm Namespace | No | - |
| REQ-002 | requirement | Shared ConfigMap | No | - |
| REQ-003 | requirement | k3d Cluster Lifecycle | No | - |
| SC-001 | scenario | Apply Namespace to Clean Cluster | No | - |
| SC-002 | scenario | Reapply Existing Namespace | No | - |
| SC-003 | scenario | Apply ConfigMap with Existing Namespace | No | - |
| SC-004 | scenario | Reapply Existing ConfigMap | No | - |
| SC-005 | scenario | ConfigMap Service URLs Follow K8s DNS Pattern | No | - |
| SC-006 | scenario | Create Cluster Without Prior Cluster | No | - |
| SC-007 | scenario | Create Cluster When Already Exists | No | - |
| SC-008 | scenario | Delete Existing Cluster | No | - |
| SC-009 | scenario | Delete Non-Existent Cluster | No | - |
| SC-00A | scenario | Start and Stop Preserve Cluster State | No | - |
| SC-00B | scenario | Status Shows Pods and Services When Context Matches | No | - |

## Technical Context

> Codebase analysis was not performed for this sprint. Implementation should begin
> with a codebase exploration phase to identify relevant patterns and integration
> points.

This is a greenfield project. The reference implementation in the eve-cli monorepo
(`../../../eve-cli/main/deploy/`) provides configuration values, resource limits, and
service topology to inform the implementation, but all artifacts are written as original
infra specifications — not ports or extractions. The three artifacts this sprint creates
are:

- `k8s/namespace.yaml` — Kubernetes Namespace resource, applied first before any other manifest
- `k8s/configmap.yaml` — Kubernetes ConfigMap named `eve-realm-config` with 14 environment variables
- `scripts/k3d-cluster.sh` — Bash script with five subcommands: `create`, `delete`, `start`, `stop`, `status`

## Implementation Sections

### REQ-001: Eve Realm Namespace

**Entity**: `.software/entities/requirements/REQ-001.md`
**Type**: requirement
**Priority**: high

**Codebase Mapping**:
To be determined during implementation.

Files to create:
- `k8s/namespace.yaml`

**Acceptance Criteria**:
- **AC-1**: Given a Kubernetes cluster with no existing `eve-realm` namespace, when `kubectl apply -f k8s/namespace.yaml` is executed, then the namespace `eve-realm` is created with labels `app.kubernetes.io/part-of: eve-realm`.
- **AC-2**: Given the `eve-realm` namespace already exists, when `kubectl apply -f k8s/namespace.yaml` is executed again, then the command exits successfully with `unchanged` and no duplicate or error occurs.
- **AC-3**: Given the namespace manifest, when inspected, then it contains explicit `apiVersion: v1`, `kind: Namespace`, `metadata.name: eve-realm`, and the label `app.kubernetes.io/part-of: eve-realm`. No Helm or Kustomize annotations are present.
- **AC-4**: Given any other infra manifest in this sprint (ConfigMap, NATS, Redis), when applied, then it targets the `eve-realm` namespace — confirming the namespace serves as the cluster-wide scope for all infra resources.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

The namespace manifest is the simplest artifact in the sprint and must be applied before any other manifest. The apply order in the Makefile `deploy` target must place `k8s/namespace.yaml` first. Use `kubectl apply`, not `kubectl create`, to keep the operation idempotent.

---

### REQ-002: Shared ConfigMap

**Entity**: `.software/entities/requirements/REQ-002.md`
**Type**: requirement
**Priority**: high

**Codebase Mapping**:
To be determined during implementation.

Files to create:
- `k8s/configmap.yaml`

**Acceptance Criteria**:
- **AC-1**: Given the `eve-realm` namespace exists, when `kubectl apply -f k8s/configmap.yaml` is executed, then a ConfigMap named `eve-realm-config` is created in the `eve-realm` namespace.
- **AC-2**: Given the ConfigMap is applied, when a plugin pod uses `envFrom: configMapRef: name: eve-realm-config`, then all 14 environment variables are injected into the pod's environment.
- **AC-3**: Given the ConfigMap manifest, when inspected, then it contains exactly the following keys: `EVE_REALM_DSN`, `EVE_REALM_CONTROL_DSN`, `EVE_REALM_LOG_LEVEL`, `EVE_REALM_AUTH_DOMAIN`, `EVE_REALM_AUTH_AUDIENCE`, `EVE_REALM_AUTH_CLIENT_ID_CLI`, `EVE_REALM_AUTH_CLIENT_ID_WEB`, `EVE_REALM_SERVER_URL`, `EVE_REALM_NATS_URL`, `EVE_REALM_NATS_WS_URL`, `EVE_REALM_NATS_PASSWORD`, `EVE_REALM_NATS_BROWSER_TOKEN`, `EVE_REALM_REDIS_URL`, `EVE_REALM_NEO4J_URI`.
- **AC-4**: Given the service URL keys in the ConfigMap, when inspected, then each internal service URL follows the K8s DNS pattern `<protocol>://<service-name>.<namespace>.svc.cluster.local:<port>` using the `eve-realm` namespace and `eve-realm-*` service names.
- **AC-5**: Given the `eve-realm-config` ConfigMap already exists, when `kubectl apply -f k8s/configmap.yaml` is executed again, then the command exits successfully with `unchanged` and no error occurs.
- **AC-6**: Given the ConfigMap manifest, when inspected, then it carries the label `app.kubernetes.io/part-of: eve-realm` and targets the `eve-realm` namespace. No Helm or Kustomize annotations are present.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

The ConfigMap depends on the namespace existing (REQ-001 must be applied first). The 14 keys and their default values for local k3d development are:

| Key | Default value |
|-----|--------------|
| `EVE_REALM_DSN` | `postgres://eve-realm:eve-realm@host.docker.internal:5432/eve-realm?sslmode=disable` |
| `EVE_REALM_CONTROL_DSN` | `postgres://eve-realm:eve-realm@host.docker.internal:5432/eve-realm_control_plane?sslmode=disable` |
| `EVE_REALM_LOG_LEVEL` | `debug` |
| `EVE_REALM_AUTH_DOMAIN` | `dev-twmpbn8pib668naq.us.auth0.com` |
| `EVE_REALM_AUTH_AUDIENCE` | `https://api.eve-realm.dev` |
| `EVE_REALM_AUTH_CLIENT_ID_CLI` | `Z1WxIkqdujlNd7LbgN808SFK9You2fN7` |
| `EVE_REALM_AUTH_CLIENT_ID_WEB` | `bAQpA616A9dXfq5JzV6OXeSeILcNjvvi` |
| `EVE_REALM_SERVER_URL` | `` (empty) |
| `EVE_REALM_NATS_URL` | `nats://eve-realm-nats.eve-realm.svc.cluster.local:4222` |
| `EVE_REALM_NATS_WS_URL` | `ws://eve-realm-nats.eve-realm.svc.cluster.local:9222` |
| `EVE_REALM_NATS_PASSWORD` | `eve-realm-nats` |
| `EVE_REALM_NATS_BROWSER_TOKEN` | `eve-realm-browser` |
| `EVE_REALM_REDIS_URL` | `redis://eve-realm-redis.eve-realm.svc.cluster.local:6379` |
| `EVE_REALM_NEO4J_URI` | `bolt://neo4j:eve-realm@host.docker.internal:7687/eve-realm` |

Note: `EVE_REALM_NATS_PASSWORD` and `EVE_REALM_NATS_BROWSER_TOKEN` are stored in plaintext in this ConfigMap, which is acceptable for local k3d development. Migration to Kubernetes Secrets is deferred. Plugin service URLs are not included — plugins are discovered dynamically via NATS.

---

### REQ-003: k3d Cluster Lifecycle

**Entity**: `.software/entities/requirements/REQ-003.md`
**Type**: requirement
**Priority**: high

**Codebase Mapping**:
To be determined during implementation.

Files to create:
- `scripts/k3d-cluster.sh`

**Acceptance Criteria**:
- **AC-1**: Given no existing k3d cluster named `eve-realm`, when `scripts/k3d-cluster.sh create` is executed, then a k3d cluster named `eve-realm` is created with a local registry at `k3d-eve-realm-registry.localhost:5100`, API port 6550, NodePort mapping 30000, and Traefik disabled.
- **AC-2**: Given a k3d cluster named `eve-realm` already exists, when `scripts/k3d-cluster.sh create` is executed, then the script prints an informational message and exits without error and without modifying the existing cluster.
- **AC-3**: Given an existing k3d cluster named `eve-realm`, when `scripts/k3d-cluster.sh delete` is executed, then the cluster and its associated local registry are both deleted. The operation is idempotent — running it when neither exists produces no error.
- **AC-4**: Given a running k3d cluster named `eve-realm`, when `scripts/k3d-cluster.sh stop` is executed and then `scripts/k3d-cluster.sh start` is executed, then the cluster resumes without data loss, and the kubectl context points to the cluster.
- **AC-5**: Given any cluster state, when `scripts/k3d-cluster.sh status` is executed and the current kubectl context matches the `eve-realm` cluster, then the output includes: list of k3d clusters, list of k3d registries, list of pods in the `eve-realm` namespace, and list of services in the `eve-realm` namespace.
- **AC-6**: Given the script file, when inspected, then it uses `#!/usr/bin/env bash` with `set -euo pipefail`, defines named constants for `CLUSTER_NAME`, `REGISTRY_NAME`, `REGISTRY_PORT`, `API_PORT`, and `HTTP_PORT`, and organises each subcommand as a separate function.
- **AC-7**: Given the `create` subcommand completes successfully, when output is displayed, then it shows the cluster-info output, the registry address (`k3d-eve-realm-registry.localhost:5100`), the NodePort address, and next steps for applying infra manifests.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

Script constants:

| Constant | Value |
|----------|-------|
| `CLUSTER_NAME` | `eve-realm` |
| `REGISTRY_NAME` | `eve-realm-registry.localhost` |
| `REGISTRY_PORT` | `5100` |
| `API_PORT` | `6550` |
| `HTTP_PORT` | `30000` |

The `create` subcommand must: (1) guard against duplicate cluster creation, (2) create the registry with `k3d registry create` (ignore existing), (3) create the cluster with `--registry-use k3d-eve-realm-registry.localhost:5100 --api-port 6550 --port 30000:30000@server:0 --k3s-arg "--disable=traefik@server:0" --wait`. The `delete` subcommand uses `|| true` for both cluster and registry deletion to ensure idempotency.

---

### SC-001: Apply Namespace to Clean Cluster

**Entity**: `.software/entities/scenarios/SC-001.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `k8s/namespace.yaml`

**Acceptance Criteria**:
- **AC-1**: Given a k3d cluster with no `eve-realm` namespace, when `kubectl apply -f k8s/namespace.yaml` is executed, then `kubectl get namespace eve-realm` returns the namespace with status `Active`.
- **AC-2**: Given the namespace was just created, when `kubectl get namespace eve-realm -o jsonpath='{.metadata.labels}'` is executed, then the output includes `app.kubernetes.io/part-of: eve-realm`.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario is the happy path for REQ-001 AC-1. It confirms that a freshly initialised k3d cluster can accept the namespace manifest without errors.

---

### SC-002: Reapply Existing Namespace

**Entity**: `.software/entities/scenarios/SC-002.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `k8s/namespace.yaml` (idempotency)

**Acceptance Criteria**:
- **AC-1**: Given the `eve-realm` namespace already exists in the cluster, when `kubectl apply -f k8s/namespace.yaml` is executed a second time, then the command exits with code 0 and prints `namespace/eve-realm unchanged`.
- **AC-2**: Given the namespace was reapplied, when `kubectl get namespace eve-realm` is executed, then the namespace status remains `Active` and the labels are unchanged.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates the idempotency requirement in REQ-001 AC-2. `kubectl apply` must be used (not `kubectl create`) to guarantee safe re-runs.

---

### SC-003: Apply ConfigMap with Existing Namespace

**Entity**: `.software/entities/scenarios/SC-003.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `k8s/configmap.yaml` (happy path)

**Acceptance Criteria**:
- **AC-1**: Given the `eve-realm` namespace exists and no `eve-realm-config` ConfigMap exists, when `kubectl apply -f k8s/configmap.yaml` is executed, then the ConfigMap is created and `kubectl get configmap eve-realm-config -n eve-realm` returns the resource.
- **AC-2**: Given the ConfigMap was just created, when `kubectl get configmap eve-realm-config -n eve-realm -o jsonpath='{.data}'` is executed, then all 14 expected keys are present with their default values.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-002 AC-1 and AC-2. Depends on SC-001 having passed (namespace must exist before ConfigMap can be applied).

---

### SC-004: Reapply Existing ConfigMap

**Entity**: `.software/entities/scenarios/SC-004.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `k8s/configmap.yaml` (idempotency)

**Acceptance Criteria**:
- **AC-1**: Given the `eve-realm-config` ConfigMap already exists in the `eve-realm` namespace, when `kubectl apply -f k8s/configmap.yaml` is executed again, then the command exits with code 0 and prints `configmap/eve-realm-config unchanged`.
- **AC-2**: Given the ConfigMap was reapplied, when `kubectl get configmap eve-realm-config -n eve-realm -o jsonpath='{.data}'` is executed, then all 14 keys retain their original values.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-002 AC-5. Mirrors the namespace idempotency scenario (SC-002) for the ConfigMap resource.

---

### SC-005: ConfigMap Service URLs Follow K8s DNS Pattern

**Entity**: `.software/entities/scenarios/SC-005.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `k8s/configmap.yaml` (URL format correctness)

**Acceptance Criteria**:
- **AC-1**: Given the `eve-realm-config` ConfigMap, when the values of `EVE_REALM_NATS_URL`, `EVE_REALM_NATS_WS_URL`, and `EVE_REALM_REDIS_URL` are inspected, then each URL matches the pattern `<protocol>://<service-name>.eve-realm.svc.cluster.local:<port>` where service names use the `eve-realm-` prefix.
- **AC-2**: Given the ConfigMap's `EVE_REALM_NATS_URL` value, when compared against the NATS service name defined in the NATS deployment, then both use `eve-realm-nats` as the service name and port `4222`.
- **AC-3**: Given the ConfigMap's `EVE_REALM_REDIS_URL` value, when compared against the Redis service name defined in the Redis deployment, then both use `eve-realm-redis` as the service name and port `6379`.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-002 AC-4. The K8s DNS convention ensures that service URLs are resolvable inside the cluster without any external DNS configuration. The service name in the URL must exactly match the `metadata.name` of the corresponding Service resource.

---

### SC-006: Create Cluster Without Prior Cluster

**Entity**: `.software/entities/scenarios/SC-006.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `scripts/k3d-cluster.sh create` (happy path)

**Acceptance Criteria**:
- **AC-1**: Given no k3d cluster named `eve-realm` exists, when `scripts/k3d-cluster.sh create` is executed, then the command exits with code 0, a cluster named `eve-realm` is listed by `k3d cluster list`, and a registry named `k3d-eve-realm-registry.localhost` is listed by `k3d registry list`.
- **AC-2**: Given the cluster was just created, when `kubectl cluster-info` is executed, then the API server is reachable and the current context is set to the `eve-realm` cluster.
- **AC-3**: Given the cluster was just created, when `kubectl get nodes` is executed, then at least one node is in `Ready` status.
- **AC-4**: Given the cluster was just created, when the script output is reviewed, then it includes the registry address (`k3d-eve-realm-registry.localhost:5100`) and the NodePort address (host port 30000).

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-003 AC-1 and AC-7. The `--wait` flag on `k3d cluster create` ensures the command blocks until the cluster is fully ready before reporting success.

---

### SC-007: Create Cluster When Already Exists

**Entity**: `.software/entities/scenarios/SC-007.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `scripts/k3d-cluster.sh create` (duplicate guard)

**Acceptance Criteria**:
- **AC-1**: Given a k3d cluster named `eve-realm` already exists, when `scripts/k3d-cluster.sh create` is executed, then the command exits with code 1 and prints a message indicating the cluster already exists and suggesting `start`.
- **AC-2**: Given the duplicate guard triggered, when `k3d cluster list` is executed, then only one cluster named `eve-realm` is listed (no duplicate was created).

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-003 AC-2. The guard must check for the cluster by name before attempting creation and exit gracefully rather than propagating the k3d error.

---

### SC-008: Delete Existing Cluster

**Entity**: `.software/entities/scenarios/SC-008.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `scripts/k3d-cluster.sh delete`

**Acceptance Criteria**:
- **AC-1**: Given a running k3d cluster named `eve-realm` and a registry named `k3d-eve-realm-registry.localhost`, when `scripts/k3d-cluster.sh delete` is executed, then the command exits with code 0, the cluster is no longer listed by `k3d cluster list`, and the registry is no longer listed by `k3d registry list`.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates the first half of REQ-003 AC-3. Both cluster and registry must be deleted — registry cleanup is not automatic when the cluster is deleted.

---

### SC-009: Delete Non-Existent Cluster

**Entity**: `.software/entities/scenarios/SC-009.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `scripts/k3d-cluster.sh delete` (idempotency)

**Acceptance Criteria**:
- **AC-1**: Given no k3d cluster named `eve-realm` exists and no registry named `k3d-eve-realm-registry.localhost` exists, when `scripts/k3d-cluster.sh delete` is executed, then the command exits with code 0 and no error is printed.

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates the idempotency half of REQ-003 AC-3. The `|| true` pattern on both `k3d cluster delete` and `k3d registry delete` calls ensures that a missing resource does not cause a non-zero exit.

---

### SC-00A: Start and Stop Preserve Cluster State

**Entity**: `.software/entities/scenarios/SC-00A.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `scripts/k3d-cluster.sh start` and `scripts/k3d-cluster.sh stop`

**Acceptance Criteria**:
- **AC-1**: Given a running k3d cluster with infra manifests applied and pods running in `eve-realm`, when `scripts/k3d-cluster.sh stop` is executed, then the command exits with code 0 and the cluster enters a stopped state.
- **AC-2**: Given a stopped k3d cluster, when `scripts/k3d-cluster.sh start` is executed, then the command exits with code 0 and the cluster resumes without destroying or modifying previously applied Kubernetes resources.
- **AC-3**: Given the cluster was started after a stop, when `kubectl get pods -n eve-realm` is executed, then previously running pods are present (though they may be restarting — the resources themselves are preserved).

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-003 AC-4. Start and stop are thin wrappers over `k3d cluster start` and `k3d cluster stop` respectively. The key guarantee is state preservation — Docker containers are paused and resumed, not recreated.

---

### SC-00B: Status Shows Pods and Services When Context Matches

**Entity**: `.software/entities/scenarios/SC-00B.md`
**Type**: scenario
**Priority**: (from entity)

**Codebase Mapping**:
To be determined during implementation.

Validates: `scripts/k3d-cluster.sh status`

**Acceptance Criteria**:
- **AC-1**: Given a running k3d cluster and the current kubectl context set to `k3d-eve-realm`, when `scripts/k3d-cluster.sh status` is executed, then the output includes: (1) k3d cluster list, (2) k3d registry list, (3) `kubectl get pods -n eve-realm`, (4) `kubectl get services -n eve-realm`.
- **AC-2**: Given a running k3d cluster but the current kubectl context does NOT match `k3d-eve-realm`, when `scripts/k3d-cluster.sh status` is executed, then the output includes the cluster and registry lists but skips the pod and service queries (no error from kubectl context mismatch).

**Implementation Notes**:
Feasibility not assessed. Review dependencies before starting.

This scenario validates REQ-003 AC-5. The context check prevents kubectl errors when the user has switched to a different context. The status command must detect context mismatch gracefully rather than failing.

---

## Documentation Tasks

### RELEASES.md Entry

**Required**: Always

Add an entry to RELEASES.md documenting:
- Sprint ID and title: SP-001 — Foundation Layer — Namespace, ConfigMap, k3d Cluster
- Summary of changes delivered: Kubernetes namespace manifest (`k8s/namespace.yaml`), shared ConfigMap manifest (`k8s/configmap.yaml`) with 14 environment variables, and k3d cluster lifecycle script (`scripts/k3d-cluster.sh`) with `create`, `delete`, `start`, `stop`, and `status` subcommands.
- Entity IDs included: REQ-001, REQ-002, REQ-003, SC-001, SC-002, SC-003, SC-004, SC-005, SC-006, SC-007, SC-008, SC-009, SC-00A, SC-00B
- Date of completion

This entry should be appended to the existing RELEASES.md file. Do not read or modify existing entries.

### README.md Update

**Required**: User-facing changes detected

Update README.md to reflect:
- New `k8s/namespace.yaml` — describes the `eve-realm` namespace and its role as the cluster-wide scope for all infra resources
- New `k8s/configmap.yaml` — describes the `eve-realm-config` shared ConfigMap, the 15 environment variable keys it exposes, and how plugins consume it via `envFrom`
- New `scripts/k3d-cluster.sh` — documents all five subcommands (`create`, `delete`, `start`, `stop`, `status`) with usage examples
- Makefile targets: `make cluster-create`, `make cluster-delete`, `make cluster-start`, `make cluster-stop`, `make cluster-status`, `make deploy` — explain what each target does
- Prerequisites: k3d and kubectl must be installed; Docker must be running
- Getting started sequence: `make cluster-create` → `make deploy` → verify with `make cluster-status`

## Out of Scope

- NATS messaging service (deployment, service, configmap) — deferred to SP-002
- Redis cache service (deployment, service) — deferred to SP-002
- Cluster verification job (`k8s/verify/`) — deferred to a later sprint
- `scripts/deploy-all.sh` orchestration script — deferred; requires cross-repo coordination design decisions
- `k8s/ingress.yaml` base Ingress resource — deferred; requires design decision on Ingress controller selection
- Migration of `EVE_REALM_NATS_PASSWORD` and `EVE_REALM_NATS_BROWSER_TOKEN` from ConfigMap to Kubernetes Secrets — out of scope for local development baseline
- JetStream enablement in NATS configuration — not part of this sprint's scope
- Production hardening (maxmemory, Redis auth, Secret management) — local k3d development baseline only

## Prerequisites

- k3d v5+ must be installed on the developer machine (`k3d version`)
- kubectl must be installed and configured (`kubectl version --client`)
- Docker must be running (k3d requires Docker as the container runtime)
- The `eve-realm` namespace must not conflict with any existing namespace in the target cluster before `create` is called
