# eve-realm-infra

Cluster-level infrastructure for the Eve Realm platform. Provides the Kubernetes foundation
that all plugins and the hub depend on: namespace definition, shared ConfigMap, k3d cluster
lifecycle management, NATS messaging, Redis caching, ingress routing, and deployment
orchestration.

## Prerequisites

| Tool | Minimum version | Purpose |
|------|----------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | Running daemon required | Container runtime for k3d nodes |
| [k3d](https://k3d.io/) | v5+ | Local Kubernetes cluster via Docker |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Compatible with cluster version | Apply manifests and inspect cluster state |

## Project Structure

```
eve-realm-infra/
├── k8s/
│   ├── namespace.yaml        # eve-realm namespace
│   └── configmap.yaml        # Shared ConfigMap (eve-realm-config)
├── scripts/
│   └── k3d-cluster.sh        # k3d cluster lifecycle (create/delete/start/stop/status)
├── Makefile                  # Convenience targets
└── README.md
```

## Getting Started

```bash
make cluster-create   # Create the k3d cluster and local registry
make deploy           # Apply namespace and ConfigMap manifests
make cluster-status   # Verify cluster and pods are running
```

## Kubernetes Manifests

### Namespace — `k8s/namespace.yaml`

Creates the `eve-realm` namespace, which is the cluster-wide scope for all Eve Realm
services. Every manifest in this repository targets this namespace. The namespace manifest
must be applied before any other manifest.

```
namespace: eve-realm
label:     app.kubernetes.io/part-of: eve-realm
```

### Shared ConfigMap — `k8s/configmap.yaml`

Creates `eve-realm-config` in the `eve-realm` namespace. This ConfigMap holds all shared
environment variables consumed by every plugin and the hub.

#### Environment variable keys

| Key | Description |
|-----|-------------|
| `EVE_REALM_DSN` | PostgreSQL connection string for the main database |
| `EVE_REALM_CONTROL_DSN` | PostgreSQL connection string for the control-plane database |
| `EVE_REALM_LOG_LEVEL` | Log verbosity level (e.g., `debug`, `info`) |
| `EVE_REALM_AUTH_DOMAIN` | Auth0 tenant domain |
| `EVE_REALM_AUTH_AUDIENCE` | Auth0 API audience identifier |
| `EVE_REALM_AUTH_CLIENT_ID_CLI` | Auth0 client ID for CLI flows |
| `EVE_REALM_AUTH_CLIENT_ID_WEB` | Auth0 client ID for web flows |
| `EVE_REALM_SERVER_URL` | Public base URL of the API server |
| `EVE_REALM_NATS_URL` | NATS server connection URL (cluster-internal) |
| `EVE_REALM_NATS_WS_URL` | NATS WebSocket URL (cluster-internal) |
| `EVE_REALM_NATS_PASSWORD` | NATS authentication password |
| `EVE_REALM_NATS_BROWSER_TOKEN` | NATS browser authentication token |
| `EVE_REALM_REDIS_URL` | Redis connection URL (cluster-internal) |
| `EVE_REALM_NEO4J_URI` | Neo4j Bolt URI |

Internal service URLs (NATS, Redis) use the Kubernetes DNS pattern:
`<service-name>.<namespace>.svc.cluster.local:<port>`.

#### Consuming the ConfigMap from a plugin

Plugins and the hub consume all keys at once using `envFrom`:

```yaml
spec:
  containers:
    - name: my-plugin
      image: k3d-eve-realm-registry.localhost:5100/my-plugin:latest
      envFrom:
        - configMapRef:
            name: eve-realm-config
```

This injects every key in `eve-realm-config` as an environment variable into the container.
Service-specific overrides can be added via a separate `env` block below `envFrom`.

## k3d Cluster Script — `scripts/k3d-cluster.sh`

Manages the local k3d cluster lifecycle. The script is idempotent where possible and
outputs colored progress messages.

**Constants**

| Constant | Value |
|----------|-------|
| Cluster name | `eve-realm` |
| Registry name | `eve-realm-registry.localhost` |
| Registry address | `k3d-eve-realm-registry.localhost:5100` |
| API server port | `6550` |
| HTTP NodePort | `30000` |

### Subcommands

#### `create` — Create cluster and registry

Creates the local registry first, then creates the k3d cluster linked to it. Guards
against duplicate cluster creation.

```bash
./scripts/k3d-cluster.sh create
```

#### `delete` — Delete cluster and registry

Removes the cluster and registry. Idempotent — safe to run even when neither exists.

```bash
./scripts/k3d-cluster.sh delete
```

#### `start` — Start a stopped cluster

Starts a previously stopped cluster, restoring all nodes.

```bash
./scripts/k3d-cluster.sh start
```

#### `stop` — Stop the cluster

Stops all cluster nodes while preserving state. Use `start` to resume.

```bash
./scripts/k3d-cluster.sh stop
```

#### `status` — Show cluster state

Lists k3d clusters and registries. When the current kubectl context is `k3d-eve-realm`,
also shows pods and services in the `eve-realm` namespace.

```bash
./scripts/k3d-cluster.sh status
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make cluster-create` | Create the k3d cluster and local Docker registry |
| `make cluster-delete` | Delete the k3d cluster and registry |
| `make cluster-start` | Start a stopped cluster |
| `make cluster-stop` | Stop the cluster (state is preserved) |
| `make cluster-status` | Show cluster, registry, pods, and services status |
| `make deploy` | Apply all infra manifests: namespace, ConfigMap |
