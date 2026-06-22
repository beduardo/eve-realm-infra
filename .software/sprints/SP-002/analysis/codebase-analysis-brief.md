# Codebase Analysis Brief

**Sprint**: SP-002
**Project Root**: /Users/bruno/repo-pessoal/eve-realm/eve-realm-infra/main
**Entity IDs**: REQ-004, SC-00C, SC-00D, SC-00E, SC-00F, SC-010, SC-011, SC-012, SC-013

## Entity Details

### REQ-004: Makefile and Versioning
- Type: requirement
- Status: active
- Tags: makefile, versioning, deploy, foundation
- Provides a Makefile with semantic versioning targets (bump-patch/minor/major), deploy/undeploy targets, and cluster lifecycle wrappers that delegate to scripts/k3d-cluster.sh. A VERSION file stores the current semver.

### SC-00C: Bump Patch Version
- Type: scenario
- Status: validated
- Tags: makefile, versioning
- Verifies make bump-patch increments patch (0.1.0 -> 0.1.1)

### SC-00D: Bump Minor Version Resets Patch
- Type: scenario
- Status: validated
- Tags: makefile, versioning
- Verifies make bump-minor increments minor and resets patch (0.1.1 -> 0.2.0)

### SC-00E: Bump Major Version Resets Minor and Patch
- Type: scenario
- Status: validated
- Tags: makefile, versioning
- Verifies make bump-major increments major and resets minor/patch (0.2.0 -> 1.0.0)

### SC-00F: Deploy Applies Manifests in Dependency Order
- Type: scenario
- Status: validated
- Tags: makefile, deploy
- Verifies make deploy applies namespace first, then configmap, then service directories

### SC-010: Undeploy Removes Services but Preserves Namespace
- Type: scenario
- Status: validated
- Tags: makefile, deploy
- Verifies make undeploy deletes services with --ignore-not-found but keeps namespace

### SC-011: Undeploy-Local Deletes Entire Namespace
- Type: scenario
- Status: validated
- Tags: makefile, deploy
- Verifies make undeploy-local deletes the entire eve-realm namespace

### SC-012: Cluster Targets Delegate to k3d Script
- Type: scenario
- Status: validated
- Tags: makefile, cluster
- Verifies make cluster-create/delete/start/stop/status each delegate to scripts/k3d-cluster.sh

### SC-013: k3d-Status Shows Namespace Resources
- Type: scenario
- Status: validated
- Tags: makefile, cluster
- Verifies make k3d-status shows pods, services, and events in eve-realm namespace

## Focus Areas
- Existing Makefile content (if any)
- Existing VERSION file (if any)
- scripts/k3d-cluster.sh interface (verb arguments)
- k8s/ manifest structure for deploy ordering
- Any existing deploy patterns from SP-001
