# Spec Writer Brief

**Sprint**: SP-001
**Sprint Title**: Foundation Layer — Namespace, ConfigMap, k3d Cluster
**Project Root**: /Users/bruno/repo-pessoal/eve-realm/eve-realm-infra/main
**Sprint Folder**: /Users/bruno/repo-pessoal/eve-realm/eve-realm-infra/main/.software/sprints/SP-001
**Date**: 2026-06-22

## Entity List

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

## Analysis Artifacts

- Codebase Analysis: not available (greenfield project)
- Feasibility Reports: not assessed (greenfield project)

## Project Context

Eve Realm Infra is the cluster-level infrastructure for the Eve Realm platform. It provides
the Kubernetes foundation that all plugins and the hub depend on: namespace definition,
shared ConfigMaps, NATS messaging, Redis caching, ingress routing, k3d cluster management,
and deployment orchestration. The infra repo owns no application code — it deploys and
configures the shared services that plugins consume.

Project stats: 3 requirements (active), 11 scenarios (validated), 1 change request (in-progress).

This is a greenfield project — no existing code to map against. The sprint produces:
- `k8s/namespace.yaml` — Kubernetes namespace manifest
- `k8s/configmap.yaml` — Shared ConfigMap with 14 environment variables
- `scripts/k3d-cluster.sh` — k3d cluster lifecycle management script (5 commands)

### Key conventions (from CLAUDE.md)

- No application code, no Docker build, no binary — artifacts are YAML manifests and shell scripts
- Explicit `apiVersion` and `kind` — no Helm, no Kustomize
- Labels: `app: <service-name>`, `app.kubernetes.io/part-of: eve-realm`
- Bash scripts with `set -euo pipefail`
- Namespace: `eve-realm`

## Flags

- readme_update_needed: true
