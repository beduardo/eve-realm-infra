# Codebase Analysis

**Sprint**: SP-002
**Analyzed**: 2026-06-22
**Entities Mapped**: 9

---

## Entity-to-Code Mapping

| Entity ID | Type | Related Files | Notes |
|-----------|------|---------------|-------|
| REQ-004 | requirement | `Makefile`, `VERSION` | Makefile exists (missing bump-*, undeploy, undeploy-local, k3d-status targets). VERSION does NOT exist — must be created |
| SC-00C | scenario | `Makefile` (bump-patch target) | Target absent |
| SC-00D | scenario | `Makefile` (bump-minor target) | Target absent |
| SC-00E | scenario | `Makefile` (bump-major target) | Target absent |
| SC-00F | scenario | `Makefile` (deploy target), `k8s/namespace.yaml`, `k8s/configmap.yaml` | deploy target partially exists (namespace + configmap only); no service dirs yet |
| SC-010 | scenario | `Makefile` (undeploy target) | Target absent; service dirs (nats/, redis/) not yet in k8s/ |
| SC-011 | scenario | `Makefile` (undeploy-local target) | Target absent |
| SC-012 | scenario | `Makefile` (cluster-* targets) | All 5 cluster targets already present and correctly delegate |
| SC-013 | scenario | `Makefile` (k3d-status target) | Target absent |

## Implementation Patterns

### Pattern 1: Semver bump via awk
The bump-patch/minor/major targets split the VERSION file with `awk -F.`, increment the relevant component with shell arithmetic, then overwrite the file with `echo "..." > VERSION`.

### Pattern 2: Dependency-ordered kubectl apply
The existing `deploy` target already applies namespace first, then configmap. The same sequential approach extends to service directories once k8s/nats/ and k8s/redis/ are added.

### Pattern 3: kubectl delete --ignore-not-found for undeploy
`undeploy` uses `kubectl delete -f <manifest> --ignore-not-found` for services. `undeploy-local` deletes the entire namespace.

### Pattern 4: k3d-status with pods, services, and events
Runs three kubectl commands: `get pods -n eve-realm`, `get services -n eve-realm`, and `get events -n eve-realm --sort-by='.lastTimestamp' | tail -20`.

### Pattern 5: Script delegation for cluster targets (already implemented)
The cluster-create/delete/start/stop/cluster-status targets already exist and correctly call `./scripts/k3d-cluster.sh <verb>`. SC-012 is already satisfied.

## Files to Create

| File | Purpose | Entities |
|------|---------|----------|
| `VERSION` | Stores current semver string (initial `0.1.0`) | REQ-004 AC 1, SC-00C, SC-00D, SC-00E |

## Files to Modify

| File | Modification | Entities |
|------|--------------|----------|
| `Makefile` | Add bump-patch, bump-minor, bump-major targets | REQ-004 AC 2-4, SC-00C, SC-00D, SC-00E |
| `Makefile` | Extend deploy target for service directories (conditional apply) | REQ-004 AC 5, SC-00F |
| `Makefile` | Add undeploy target (delete services, preserve namespace) | REQ-004 AC 6, SC-010 |
| `Makefile` | Add undeploy-local target (delete entire namespace) | REQ-004 AC 7, SC-011 |
| `Makefile` | Add k3d-status target (pods, services, events) | REQ-004 AC 13, SC-013 |
| `Makefile` | Expand .PHONY declaration | REQ-004 all ACs |

## Key Technical Notes

- **SC-012 is already fully satisfied.** No changes needed for cluster targets.
- **VERSION file initial content**: `0.1.0` with trailing newline.
- **deploy target**: Use conditional apply for service dirs (`[ -d k8s/nats ] && kubectl apply -f k8s/nats/ || true`).
- **undeploy must NOT delete configmap** — only service manifests.
- **k3d-status is distinct from cluster-status** — k3d-status always shows pods, services, AND events via direct kubectl calls.
- **Namespace**: `eve-realm` (not `eve5` from eve-cli).
