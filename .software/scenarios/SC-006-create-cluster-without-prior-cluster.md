---
content_hash: c7b5003376334e361bfe90f76db5256576d359474c03e551e53849fd2a284b95
created: "2026-06-22"
id: SC-006
related_changes: []
related_reqs:
    - REQ-003
related_testcases: []
source: manual
status: implemented
tags:
    - k3d
    - cluster
    - scripts
title: Create Cluster Without Prior Cluster
type: happy-path
updated: "2026-06-22"
---

# SC-006: Create Cluster Without Prior Cluster

## Preconditions

- k3d is installed
- No k3d cluster named `eve-realm` exists
- Docker is running

## Steps

1. Run `scripts/k3d-cluster.sh create`

## Expected Result

- A k3d registry `eve-realm-registry.localhost` is created on port 5100
- A k3d cluster `eve-realm` is created with:
  - Registry connected at `k3d-eve-realm-registry.localhost:5100`
  - Kubernetes API on port 6550
  - NodePort 30000 mapped to host port 30000
  - NodePort 30051 mapped to host port 30051 (gRPC)
  - Traefik disabled
- `kubectl cluster-info` output is printed
- Registry address and NodePort addresses (HTTP and gRPC) are displayed
- Port-forwarding verification runs: each NodePort is tested for host reachability and SSH tunnels are forced if needed (Lima/Rancher Desktop only)
- Next steps are printed
- Exit code is 0
