# Sprint SP-002: Makefile and Versioning

**Created**: 2026-06-22
**Status**: Specified
**Entities**: 9

---

## Overview

This sprint completes the Makefile tooling for the eve-realm-infra repository by adding semantic versioning targets, a deploy/undeploy lifecycle, and a namespace-scoped status view. The existing Makefile already delegates cluster lifecycle operations to `scripts/k3d-cluster.sh` — this sprint extends it with the missing bump-*, undeploy, undeploy-local, and k3d-status targets, and creates the `VERSION` file that anchors the semver workflow. Together these changes give operators a single, consistent interface for every infrastructure management task without requiring any external tooling beyond `kubectl` and `k3d`.

## Entity Inventory

| ID | Type | Title | Partial | Scope Notes |
|----|------|-------|---------|-------------|
| REQ-004 | requirement | Makefile and Versioning | no | - |
| SC-00C | scenario | Bump Patch Version | no | - |
| SC-00D | scenario | Bump Minor Version Resets Patch | no | - |
| SC-00E | scenario | Bump Major Version Resets Minor and Patch | no | - |
| SC-00F | scenario | Deploy Applies Manifests in Dependency Order | no | - |
| SC-010 | scenario | Undeploy Removes Services but Preserves Namespace | no | - |
| SC-011 | scenario | Undeploy-Local Deletes Entire Namespace | no | - |
| SC-012 | scenario | Cluster Targets Delegate to k3d Script | no | Already satisfied — no implementation changes required |
| SC-013 | scenario | k3d-Status Shows Namespace Resources | no | - |

## Technical Context

The current Makefile (21 lines) already contains the six targets `cluster-create`, `cluster-delete`, `cluster-start`, `cluster-stop`, `cluster-status`, and `deploy`. The `deploy` target applies `k8s/namespace.yaml` then `k8s/configmap.yaml`. The `.PHONY` declaration covers only these six targets.

**Missing targets** (to be added):
- `bump-patch`, `bump-minor`, `bump-major` — semver increment via `awk -F.` splitting of the `VERSION` file
- Extension of `deploy` — conditional apply for `k8s/nats/` and `k8s/redis/` directories when they exist
- `undeploy` — deletes service manifests (`k8s/nats/`, `k8s/redis/`) with `--ignore-not-found`; does NOT delete namespace or configmap
- `undeploy-local` — deletes the `eve-realm` namespace entirely with `--ignore-not-found`
- `k3d-status` — runs `kubectl get pods`, `kubectl get services`, and `kubectl get events` scoped to `eve-realm`

**File to create**: `VERSION` at repository root, initial content `0.1.0` with trailing newline.

**File to modify**: `Makefile` — add all missing targets and expand `.PHONY`.

**Key patterns from codebase analysis**:
- Semver bump: `awk -F. '{print $1,$2,$3}'` to split, shell arithmetic to increment, `echo "M.m.p" > VERSION` to overwrite
- Conditional service-dir apply: `[ -d k8s/nats ] && kubectl apply -f k8s/nats/ || true`
- Delete with `kubectl delete -f <path> --ignore-not-found`
- k3d-status events: `kubectl get events -n eve-realm --sort-by='.lastTimestamp' | tail -20`
- Namespace `eve-realm` throughout (not `eve5`)

**SC-012 status**: All five cluster-* targets already exist and correctly delegate to `./scripts/k3d-cluster.sh`. No code changes are needed for this scenario.

## Implementation Sections

### REQ-004: Makefile and Versioning

**Entity**: `.software/entities/requirements/REQ-004.md`
**Type**: requirement
**Priority**: high

**Codebase Mapping**:

Files to create:
- `VERSION` — repository root; initial content `0.1.0`

Files to modify:
- `Makefile` — add bump-patch, bump-minor, bump-major targets; extend deploy target; add undeploy, undeploy-local, k3d-status targets; expand `.PHONY`

**Acceptance Criteria**:

- **AC-1**: Given the repository root, when the `VERSION` file is present, then it contains a semantic version string (e.g., `0.1.0`)
- **AC-2**: Given `VERSION` contains `0.1.0`, when `make bump-patch` is run, then `VERSION` contains `0.1.1`
- **AC-3**: Given `VERSION` contains `0.1.1`, when `make bump-minor` is run, then `VERSION` contains `0.2.0` (patch resets to 0)
- **AC-4**: Given `VERSION` contains `0.2.0`, when `make bump-major` is run, then `VERSION` contains `1.0.0` (minor and patch reset to 0)
- **AC-5**: Given infra manifests are present, when `make deploy` is run, then `k8s/namespace.yaml` is applied first, `k8s/configmap.yaml` second, and any present service directories (`k8s/nats/`, `k8s/redis/`) are applied in sequence after configmap
- **AC-6**: Given services are deployed, when `make undeploy` is run, then service manifests in `k8s/nats/` and `k8s/redis/` are deleted with `--ignore-not-found`, and the namespace and configmap remain intact
- **AC-7**: Given the cluster is running, when `make undeploy-local` is run, then the entire `eve-realm` namespace is deleted with `--ignore-not-found`
- **AC-8**: When `make cluster-create` is run, then `scripts/k3d-cluster.sh create` is called
- **AC-9**: When `make cluster-delete` is run, then `scripts/k3d-cluster.sh delete` is called
- **AC-10**: When `make cluster-start` is run, then `scripts/k3d-cluster.sh start` is called
- **AC-11**: When `make cluster-stop` is run, then `scripts/k3d-cluster.sh stop` is called
- **AC-12**: When `make cluster-status` is run, then `scripts/k3d-cluster.sh status` is called
- **AC-13**: Given the cluster is running, when `make k3d-status` is run, then pods, services, and recent events in the `eve-realm` namespace are displayed

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The semver bump targets have no external dependencies — they rely only on `awk` and shell arithmetic available in any POSIX environment. The deploy and undeploy targets require `kubectl` to be configured against the target cluster. The k3d-status target requires `kubectl` access and assumes the `eve-realm` namespace exists.

The `undeploy` target must be written defensively: if `k8s/nats/` or `k8s/redis/` do not exist at the time `undeploy` is called, the target must not fail. Use conditional directory checks or rely on `--ignore-not-found` with directory flags appropriately.

---

### SC-00C: Bump Patch Version

**Entity**: `.software/entities/scenarios/SC-00C.md`
**Type**: scenario
**Priority**: high

**Codebase Mapping**:
- `Makefile` — `bump-patch` target (to be added)
- `VERSION` — file to be created with initial content `0.1.0`

**Acceptance Criteria**:

- **AC-1**: Given `VERSION` contains `0.1.0`, when `make bump-patch` is run, then `VERSION` contains `0.1.1`
- **AC-2**: Given `VERSION` does not exist, when `make bump-patch` is run, then the target fails with a clear error (the `VERSION` file is a prerequisite)

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The bump-patch target reads the current version from `VERSION`, splits on `.`, increments the third component, and writes the result back. No network access or cluster connectivity required.

---

### SC-00D: Bump Minor Version Resets Patch

**Entity**: `.software/entities/scenarios/SC-00D.md`
**Type**: scenario
**Priority**: high

**Codebase Mapping**:
- `Makefile` — `bump-minor` target (to be added)
- `VERSION` — must exist

**Acceptance Criteria**:

- **AC-1**: Given `VERSION` contains `0.1.1`, when `make bump-minor` is run, then `VERSION` contains `0.2.0`
- **AC-2**: Given `VERSION` contains `0.1.9`, when `make bump-minor` is run, then `VERSION` contains `0.2.0` (patch always resets regardless of value)

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The bump-minor target increments the second component and resets the third to `0`. The reset behavior is unconditional — it does not depend on the current patch value.

---

### SC-00E: Bump Major Version Resets Minor and Patch

**Entity**: `.software/entities/scenarios/SC-00E.md`
**Type**: scenario
**Priority**: high

**Codebase Mapping**:
- `Makefile` — `bump-major` target (to be added)
- `VERSION` — must exist

**Acceptance Criteria**:

- **AC-1**: Given `VERSION` contains `0.2.0`, when `make bump-major` is run, then `VERSION` contains `1.0.0`
- **AC-2**: Given `VERSION` contains `0.9.7`, when `make bump-major` is run, then `VERSION` contains `1.0.0` (both minor and patch reset)

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The bump-major target increments the first component and resets both the second and third to `0`. Reset of minor and patch is unconditional.

---

### SC-00F: Deploy Applies Manifests in Dependency Order

**Entity**: `.software/entities/scenarios/SC-00F.md`
**Type**: scenario
**Priority**: high

**Codebase Mapping**:
- `Makefile` — `deploy` target (to be extended)
- `k8s/namespace.yaml` — applied first (already referenced in existing deploy target)
- `k8s/configmap.yaml` — applied second (already referenced in existing deploy target)
- `k8s/nats/` — applied third, conditionally (directory does not yet exist)
- `k8s/redis/` — applied fourth, conditionally (directory does not yet exist)

**Acceptance Criteria**:

- **AC-1**: Given all manifests are present, when `make deploy` is run, then `kubectl apply -f k8s/namespace.yaml` executes before `kubectl apply -f k8s/configmap.yaml`
- **AC-2**: Given `k8s/nats/` exists, when `make deploy` is run, then `kubectl apply -f k8s/nats/` executes after configmap apply
- **AC-3**: Given `k8s/redis/` exists, when `make deploy` is run, then `kubectl apply -f k8s/redis/` executes after nats apply
- **AC-4**: Given `k8s/nats/` does not exist, when `make deploy` is run, then the deploy target does not fail

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The service directory steps use the conditional pattern `[ -d k8s/nats ] && kubectl apply -f k8s/nats/ || true` so that deploy succeeds even when NATS and Redis manifests have not yet been added to the repository. This makes the deploy target forward-compatible with the progressive addition of service manifests in future sprints.

---

### SC-010: Undeploy Removes Services but Preserves Namespace

**Entity**: `.software/entities/scenarios/SC-010.md`
**Type**: scenario
**Priority**: high

**Codebase Mapping**:
- `Makefile` — `undeploy` target (to be added)
- `k8s/nats/` — deleted if present
- `k8s/redis/` — deleted if present

**Acceptance Criteria**:

- **AC-1**: Given NATS and Redis are deployed, when `make undeploy` is run, then `kubectl delete -f k8s/nats/ --ignore-not-found` and `kubectl delete -f k8s/redis/ --ignore-not-found` are executed
- **AC-2**: Given `make undeploy` runs successfully, then the `eve-realm` namespace still exists
- **AC-3**: Given `make undeploy` runs successfully, then the shared configmap still exists in the `eve-realm` namespace
- **AC-4**: Given neither `k8s/nats/` nor `k8s/redis/` exist, when `make undeploy` is run, then the target exits without error

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The undeploy target must explicitly NOT include `kubectl delete -f k8s/namespace.yaml` or any configmap deletion. Service directories are deleted with `--ignore-not-found` to tolerate already-absent resources. Use conditional directory checks (`[ -d k8s/nats ]`) for the case where manifest directories have not yet been added.

---

### SC-011: Undeploy-Local Deletes Entire Namespace

**Entity**: `.software/entities/scenarios/SC-011.md`
**Type**: scenario
**Priority**: medium

**Codebase Mapping**:
- `Makefile` — `undeploy-local` target (to be added)

**Acceptance Criteria**:

- **AC-1**: Given the `eve-realm` namespace exists, when `make undeploy-local` is run, then `kubectl delete namespace eve-realm --ignore-not-found` is executed
- **AC-2**: Given the `eve-realm` namespace does not exist, when `make undeploy-local` is run, then the target exits without error (--ignore-not-found handles this)
- **AC-3**: Given `make undeploy-local` runs, then all resources within `eve-realm` (configmap, services, pods) are removed as a side effect of namespace deletion

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

This target is intentionally destructive and serves as a full local reset. It is named `undeploy-local` (not `undeploy`) to signal its nuclear nature. The `--ignore-not-found` flag makes it safe to run on a clean cluster. No individual resource deletion is needed — namespace deletion cascades to all contained resources.

---

### SC-012: Cluster Targets Delegate to k3d Script

**Entity**: `.software/entities/scenarios/SC-012.md`
**Type**: scenario
**Priority**: high

**Codebase Mapping**:
- `Makefile` — `cluster-create`, `cluster-delete`, `cluster-start`, `cluster-stop`, `cluster-status` targets (already present)
- `scripts/k3d-cluster.sh` — already receiving delegated calls

**Acceptance Criteria**:

- **AC-1**: When `make cluster-create` is run, then `./scripts/k3d-cluster.sh create` is invoked
- **AC-2**: When `make cluster-delete` is run, then `./scripts/k3d-cluster.sh delete` is invoked
- **AC-3**: When `make cluster-start` is run, then `./scripts/k3d-cluster.sh start` is invoked
- **AC-4**: When `make cluster-stop` is run, then `./scripts/k3d-cluster.sh stop` is invoked
- **AC-5**: When `make cluster-status` is run, then `./scripts/k3d-cluster.sh status` is invoked

**Implementation Notes**:

**SC-012 is already fully satisfied by the current Makefile.** All five cluster-* targets exist and correctly delegate to `./scripts/k3d-cluster.sh` with the appropriate verb. No code changes are required for this scenario. Implementation must not modify these targets.

---

### SC-013: k3d-Status Shows Namespace Resources

**Entity**: `.software/entities/scenarios/SC-013.md`
**Type**: scenario
**Priority**: medium

**Codebase Mapping**:
- `Makefile` — `k3d-status` target (to be added)

**Acceptance Criteria**:

- **AC-1**: Given the cluster is running and `eve-realm` namespace exists, when `make k3d-status` is run, then pod status in `eve-realm` is displayed
- **AC-2**: Given the cluster is running, when `make k3d-status` is run, then services in `eve-realm` are displayed
- **AC-3**: Given the cluster is running, when `make k3d-status` is run, then recent events in `eve-realm` are displayed (sorted by timestamp, last 20 entries)
- **AC-4**: `k3d-status` is distinct from `cluster-status` — it always runs direct kubectl commands, never delegates to `scripts/k3d-cluster.sh`

**Implementation Notes**:

Feasibility not assessed. Review dependencies before starting.

The k3d-status target runs three sequential kubectl commands: `kubectl get pods -n eve-realm`, `kubectl get services -n eve-realm`, and `kubectl get events -n eve-realm --sort-by='.lastTimestamp' | tail -20`. This target is intentionally separate from `cluster-status` (which delegates to the k3d script for cluster-level health) — k3d-status is a namespace-scoped resource view.

---

## Documentation Tasks

### RELEASES.md Entry

**Required**: Always

Add an entry to RELEASES.md documenting:
- Sprint ID: SP-002 and title: Makefile and Versioning
- Summary: Added semantic versioning targets (bump-patch, bump-minor, bump-major), extended deploy to apply service directories conditionally, added undeploy and undeploy-local lifecycle targets, added k3d-status for namespace-scoped resource inspection, and created the VERSION file with initial version 0.1.0
- Entity IDs included: REQ-004, SC-00C, SC-00D, SC-00E, SC-00F, SC-010, SC-011, SC-012, SC-013
- Date of completion: to be filled on delivery

This entry should be appended to the existing RELEASES.md file. Do not read or modify existing entries.

## Out of Scope

- Creating `k8s/nats/` or `k8s/redis/` manifest directories — these are produced by future sprints; the deploy target handles their absence gracefully
- `deploy-verify` target — cluster health verification is a separate concern not covered by REQ-004
- `deploy-all` target — orchestration across hub and plugins is out of scope for this sprint
- Any changes to `scripts/k3d-cluster.sh` — the script is consumed but not modified
- Helm, Kustomize, or any manifest templating tooling
- CI/CD pipeline integration for the VERSION file

## Prerequisites

- `kubectl` must be installed and configured against the target cluster for deploy, undeploy, undeploy-local, and k3d-status targets to function
- `k3d` and `scripts/k3d-cluster.sh` must be present for cluster-* targets (already satisfied — SC-012 is already implemented)
- The `VERSION` file must be created before bump-* targets can run; the initial `0.1.0` value is established as the first implementation step
- `k8s/namespace.yaml` and `k8s/configmap.yaml` must exist for the deploy target's first two steps (already present in repository)
