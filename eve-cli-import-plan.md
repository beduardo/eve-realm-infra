# Eve-CLI Import Plan — Infra Feature Extraction

This document inventories every K8s manifest, script, and Makefile target in the eve-cli
monorepo that will be extracted into `eve-realm-infra`. It serves as the source-of-truth
for creating docproject documentation and eve-software entities.

## Source Reference

- **K8s manifests source**: `eve-cli/deploy/k8s/` (6 infra manifest files)
- **Scripts source**: `eve-cli/deploy/k3d-cluster.sh` (1 shell script)
- **Makefile source**: `eve-cli/Makefile` (7 infra-related targets)
- **Target repo**: `github.com/beduardo/eve-realm-infra` (this repo)
- **HLD reference**: `eve-cli/DOCS/MULTI_REPO_HLD.md` section 2.7, section 8

## What Comes IN vs What Stays OUT

### K8s manifests

| Source file | Destination | Reason |
|------------|-------------|--------|
| `deploy/k8s/00-namespace.yaml` | **Infra** (`k8s/namespace.yaml`) | Cluster-wide namespace — not owned by any plugin |
| `deploy/k8s/configmap.yaml` | **Infra** (`k8s/configmap.yaml`) | Shared ConfigMap consumed by all plugins |
| `deploy/k8s/nats-configmap.yaml` | **Infra** (`k8s/nats/configmap.yaml`) | NATS server configuration |
| `deploy/k8s/nats-deployment.yaml` | **Infra** (`k8s/nats/deployment.yaml`) | NATS server deployment |
| `deploy/k8s/nats-service.yaml` | **Infra** (`k8s/nats/service.yaml`) | NATS ClusterIP service |
| `deploy/k8s/redis-deployment.yaml` | **Infra** (`k8s/redis/deployment.yaml`) | Redis server deployment |
| `deploy/k8s/redis-service.yaml` | **Infra** (`k8s/redis/service.yaml`) | Redis ClusterIP service |
| `deploy/k8s/verify-job.yaml` | **Infra** (`k8s/verify/job.yaml`) | Cluster verification job |
| `deploy/k8s/ingress.yaml` | **Hub** (`deploy/k8s/`) | Hub-specific NodePort Service (misnamed as ingress in eve-cli). NOT infra — see "Ingress Boundary" below |
| `deploy/k8s/frontend-deployment.yaml` | **Hub** (`deploy/k8s/`) | Hub-specific Deployment |
| `deploy/k8s/software-deployment.yaml` | **Software** (`deploy/k8s/`) | Plugin-specific Deployment |
| `deploy/k8s/software-service.yaml` | **Software** (`deploy/k8s/`) | Plugin-specific Service |
| `deploy/k8s/admin/*` | **Admin** (`deploy/k8s/`) | Plugin-specific manifests |

### Scripts

| Source file | Destination | Reason |
|------------|-------------|--------|
| `deploy/k3d-cluster.sh` | **Infra** (`scripts/k3d-cluster.sh`) | Cluster lifecycle management — not owned by any plugin |

### New artifacts (not in eve-cli)

| Artifact | Location | Reason |
|----------|----------|--------|
| `deploy-all.sh` | **Infra** (`scripts/deploy-all.sh`) | Orchestrates full deployment in dependency order: infra → hub → plugins → MCP. Replaces the monorepo's monolithic `deploy-local` target |
| `ingress.yaml` (base) | **Infra** (`k8s/ingress.yaml`) | Base Ingress resource for path-based routing. New — the eve-cli `ingress.yaml` is actually a NodePort Service (see "Ingress Boundary") |

### Ingress Boundary

The eve-cli file `deploy/k8s/ingress.yaml` is misnamed — it contains a **NodePort Service**
for the hub frontend, not an Ingress resource. It belongs to the hub, not to infra.

The HLD (section 2.7) lists `k8s/ingress.yaml` under infra and section 8 includes "ingress
base" in the infra deployment step. This refers to a **new** Ingress resource that provides
base path-routing rules for the cluster. The current eve-cli monorepo doesn't need this
because it uses NodePort directly; the multi-repo setup will introduce proper Ingress routing.

---

## K8s Manifests — Feature Inventory

### 1. Namespace (`00-namespace.yaml`)

#### 1.1 Resource Definition

- **Source**: `deploy/k8s/00-namespace.yaml`
- **Kind**: `Namespace`
- **Name**: `eve5` → `eve-realm`
- **Labels**: `app.kubernetes.io/part-of: eve5` → `app.kubernetes.io/part-of: eve-realm`
- **Ordering**: Applied first — all other manifests depend on this namespace existing
- **Idempotent**: `kubectl apply` is safe to re-run

---

### 2. Shared ConfigMap (`configmap.yaml`)

#### 2.1 Resource Definition

- **Source**: `deploy/k8s/configmap.yaml`
- **Kind**: `ConfigMap`
- **Name**: `eve5-config` → `eve-realm-config`
- **Namespace**: `eve5` → `eve-realm`
- **Labels**: `app.kubernetes.io/part-of: eve5` → `app.kubernetes.io/part-of: eve-realm`

#### 2.2 Environment Variables

All plugins consume this ConfigMap via `envFrom: configMapRef`. Every variable is renamed
from `EVE5_*` to `EVE_REALM_*`.

| Current key | New key | Purpose | Value pattern |
|------------|---------|---------|---------------|
| `EVE5_DSN` | `EVE_REALM_DSN` | Primary database connection | `postgres://eve-realm:eve-realm@host.docker.internal:5432/eve-realm?sslmode=disable` |
| `EVE5_CONTROL_DSN` | `EVE_REALM_CONTROL_DSN` | Control plane database | `postgres://eve-realm:eve-realm@host.docker.internal:5432/eve-realm_control_plane?sslmode=disable` |
| `EVE5_LOG_LEVEL` | `EVE_REALM_LOG_LEVEL` | Application log level | `debug` |
| `EVE5_AUTH_DOMAIN` | `EVE_REALM_AUTH_DOMAIN` | Auth0 tenant domain | `dev-twmpbn8pib668naq.us.auth0.com` |
| `EVE5_AUTH_AUDIENCE` | `EVE_REALM_AUTH_AUDIENCE` | Auth0 API audience | `https://api.eve-realm.dev` |
| `EVE5_AUTH_CLIENT_ID_CLI` | `EVE_REALM_AUTH_CLIENT_ID_CLI` | Auth0 CLI client ID | `Z1WxIkqdujlNd7LbgN808SFK9You2fN7` |
| `EVE5_AUTH_CLIENT_ID_WEB` | `EVE_REALM_AUTH_CLIENT_ID_WEB` | Auth0 Web client ID | `bAQpA616A9dXfq5JzV6OXeSeILcNjvvi` |
| `EVE5_SERVER_URL` | `EVE_REALM_SERVER_URL` | Remote server URL | (empty for local) |
| `EVE5_PLUGIN_SOFTWARE_URL` | `EVE_REALM_PLUGIN_SOFTWARE_URL` | Software plugin service URL | `http://eve-realm-software.eve-realm.svc.cluster.local:8080` |
| `EVE5_NATS_URL` | `EVE_REALM_NATS_URL` | NATS client connection | `nats://eve-realm-nats.eve-realm.svc.cluster.local:4222` |
| `EVE5_NATS_WS_URL` | `EVE_REALM_NATS_WS_URL` | NATS WebSocket connection | `ws://eve-realm-nats.eve-realm.svc.cluster.local:9222` |
| `EVE5_NATS_PASSWORD` | `EVE_REALM_NATS_PASSWORD` | NATS pod-level auth password | `eve-realm-nats` |
| `EVE5_NATS_BROWSER_TOKEN` | `EVE_REALM_NATS_BROWSER_TOKEN` | NATS browser-level auth token | `eve-realm-browser` |
| `EVE5_REDIS_URL` | `EVE_REALM_REDIS_URL` | Redis connection | `redis://eve-realm-redis.eve-realm.svc.cluster.local:6379` |
| `EVE5_NEO4J_URI` | `EVE_REALM_NEO4J_URI` | Neo4j graph database | `bolt://neo4j:eve-realm@host.docker.internal:7687/eve-realm` |

#### 2.3 Service URL Patterns

Internal service URLs follow the K8s DNS convention:

```
http://<service-name>.<namespace>.svc.cluster.local:<port>
```

Current: `http://eve5-software.eve5.svc.cluster.local:8080`
New: `http://eve-realm-software.eve-realm.svc.cluster.local:8080`

#### 2.4 Security Notes

- ConfigMap stores credentials in plaintext (NATS password, database credentials). This is
  acceptable for local k3d development but must migrate to K8s Secrets for production
- Auth0 client IDs are non-secret (public OAuth2 clients) and are safe in ConfigMap
- The `EVE_REALM_SERVER_URL` key is empty for local clusters — populated when connecting
  to a remote deployment

---

### 3. NATS Messaging Service

#### 3.1 NATS ConfigMap (`nats-configmap.yaml`)

- **Source**: `deploy/k8s/nats-configmap.yaml`
- **Kind**: `ConfigMap`
- **Name**: `eve5-nats-config` → `eve-realm-nats-config`
- **Namespace**: `eve5` → `eve-realm`
- **Labels**: `app: eve5-nats` → `app: eve-realm-nats`, `app.kubernetes.io/part-of: eve5` → `app.kubernetes.io/part-of: eve-realm`
- **Content**: `nats.conf` embedded in ConfigMap data

#### 3.2 NATS Server Configuration (`nats.conf`)

```
http_port: 8222                    ← monitoring/healthz endpoint

websocket {
  port: 9222                       ← browser WebSocket access
  no_tls: true                     ← TLS terminated at ingress level
}

authorization {
  users = [
    {
      user: pod                    ← pod-level NATS user (full access)
      password: $EVE5_NATS_PASSWORD
    },
    {
      user: browser                ← browser-level user (restricted)
      password: $EVE5_NATS_BROWSER_TOKEN
      permissions {
        subscribe = "eve5.ui.>"    ← can subscribe to UI events only
        publish = { deny = ">" }   ← cannot publish anything
      }
    }
  ]
}
```

- **Two-tier auth model**: `pod` user has unrestricted access (used by Go backends); `browser`
  user is read-only for UI event streams (used by React frontends via WebSocket)
- **Environment variable substitution**: NATS natively expands `$EVE5_NATS_PASSWORD` and
  `$EVE5_NATS_BROWSER_TOKEN` from container environment at startup
- **Rename notes**:
  - `$EVE5_NATS_PASSWORD` → `$EVE_REALM_NATS_PASSWORD`
  - `$EVE5_NATS_BROWSER_TOKEN` → `$EVE_REALM_NATS_BROWSER_TOKEN`
  - `"eve5.ui.>"` → `"eve-realm.ui.>"` (browser subscribe permission scope)

#### 3.3 NATS Deployment (`nats-deployment.yaml`)

- **Source**: `deploy/k8s/nats-deployment.yaml`
- **Kind**: `Deployment`
- **Name**: `eve5-nats` → `eve-realm-nats`
- **Namespace**: `eve5` → `eve-realm`
- **Replicas**: 1
- **Image**: `nats:2-alpine` (official NATS image, no custom build)
- **Args**: `["-c", "/etc/nats/nats.conf"]` — loads config from mounted volume
- **Ports**:
  - `4222` (client) — Go backend connections
  - `8222` (monitor) — HTTP monitoring and healthz
  - `9222` (ws) — WebSocket for browser clients
- **Environment** (from shared ConfigMap):
  - `EVE5_NATS_PASSWORD` → `EVE_REALM_NATS_PASSWORD` (from `eve-realm-config`)
  - `EVE5_NATS_BROWSER_TOKEN` → `EVE_REALM_NATS_BROWSER_TOKEN` (from `eve-realm-config`)
- **Volume**: ConfigMap `eve5-nats-config` → `eve-realm-nats-config` mounted at `/etc/nats/nats.conf` (subPath mount)
- **Resources**:
  - Requests: 64Mi memory, 50m CPU
  - Limits: 128Mi memory, 100m CPU
- **Health checks**:
  - Liveness: HTTP GET `/healthz` on port 8222 (initial: 5s, period: 10s, timeout: 3s, failure: 3)
  - Readiness: HTTP GET `/healthz` on port 8222 (initial: 3s, period: 5s, timeout: 3s, failure: 3)
- **Labels**: `app: eve5-nats` → `app: eve-realm-nats`

#### 3.4 NATS Service (`nats-service.yaml`)

- **Source**: `deploy/k8s/nats-service.yaml`
- **Kind**: `Service`
- **Name**: `eve5-nats` → `eve-realm-nats`
- **Namespace**: `eve5` → `eve-realm`
- **Type**: ClusterIP (internal only — not exposed outside cluster)
- **Selector**: `app: eve5-nats` → `app: eve-realm-nats`
- **Ports**:
  - `4222` (client) — Go backend NATS connections
  - `9222` (ws) — WebSocket connections proxied by the hub
- **DNS name**: `eve5-nats.eve5.svc.cluster.local` → `eve-realm-nats.eve-realm.svc.cluster.local`
- **Note**: Monitor port (8222) is NOT exposed via Service — health checks use container port directly

---

### 4. Redis Cache Service

#### 4.1 Redis Deployment (`redis-deployment.yaml`)

- **Source**: `deploy/k8s/redis-deployment.yaml`
- **Kind**: `Deployment`
- **Name**: `eve5-redis` → `eve-realm-redis`
- **Namespace**: `eve5` → `eve-realm`
- **Replicas**: 1
- **Image**: `redis:7-alpine` (official Redis image, no custom build)
- **Ports**: `6379` (redis)
- **No configuration file**: Uses Redis defaults (no persistence, no auth, no maxmemory)
- **Resources**:
  - Requests: 64Mi memory, 50m CPU
  - Limits: 128Mi memory, 100m CPU
- **Health checks**:
  - Liveness: `exec redis-cli ping` (initial: 5s, period: 10s, timeout: 3s, failure: 3)
  - Readiness: `exec redis-cli ping` (initial: 3s, period: 5s, timeout: 3s, failure: 3)
- **Labels**: `app: eve5-redis` → `app: eve-realm-redis`

#### 4.2 Redis Service (`redis-service.yaml`)

- **Source**: `deploy/k8s/redis-service.yaml`
- **Kind**: `Service`
- **Name**: `eve5-redis` → `eve-realm-redis`
- **Namespace**: `eve5` → `eve-realm`
- **Type**: ClusterIP (internal only)
- **Selector**: `app: eve5-redis` → `app: eve-realm-redis`
- **Port**: `6379` (redis)
- **DNS name**: `eve5-redis.eve5.svc.cluster.local` → `eve-realm-redis.eve-realm.svc.cluster.local`

#### 4.3 Redis Design Notes

- **No persistence**: Data is ephemeral — Redis is used for plugin registry caching (30s TTL
  keys) and session-level data. Pod restart loses all data; plugins re-register via NATS
  heartbeat within 30 seconds
- **No authentication**: Acceptable for k3d local development. Production must add
  `requirepass` and update `EVE_REALM_REDIS_URL` to include credentials
- **No maxmemory policy**: Local development only. Production needs `maxmemory` +
  `maxmemory-policy allkeys-lru`

---

### 5. Cluster Verification Job (`verify-job.yaml`)

#### 5.1 Resource Definition

- **Source**: `deploy/k8s/verify-job.yaml`
- **Kind**: `Job`
- **Name**: `eve5-verify` → `eve-realm-verify`
- **Namespace**: `eve5` → `eve-realm`
- **Labels**: `app: eve5-verify` → `app: eve-realm-verify`, `app.kubernetes.io/part-of: eve5` → `app.kubernetes.io/part-of: eve-realm`

#### 5.2 Job Configuration

- **backoffLimit**: 0 (no retries — fail fast)
- **ttlSecondsAfterFinished**: 300 (auto-cleanup after 5 minutes)
- **restartPolicy**: Never
- **Image**: `k3d-eve5-registry.localhost:5100/eve5:VERSION_PLACEHOLDER` → `k3d-eve-realm-registry.localhost:5100/eve-realm-verify:VERSION_PLACEHOLDER`
- **Command**: `/usr/local/bin/eve5-verify` → `/usr/local/bin/eve-realm-verify`
- **envFrom**: `eve5-config` → `eve-realm-config` (shared ConfigMap)
- **Resources**:
  - Requests: 32Mi memory, 50m CPU
  - Limits: 64Mi memory, 100m CPU

#### 5.3 Verification Binary

The verify job runs a custom binary that tests connectivity to cluster services. In the
monorepo, this binary is built as part of the single Docker image. In the multi-repo setup,
infra will need its own lightweight verification image or script-based alternative.

**Design decision needed**: Whether to keep a Go verification binary (requiring a Dockerfile
in infra) or replace with a shell-based Job using `busybox`/`alpine` that tests NATS, Redis,
and PostgreSQL connectivity via CLI tools. The shell approach avoids adding a build pipeline
to infra.

---

## Scripts — Feature Inventory

### 6. k3d Cluster Management (`k3d-cluster.sh`)

#### 6.1 Script Overview

- **Source**: `deploy/k3d-cluster.sh`
- **Shell**: `bash` with `set -euo pipefail`
- **Commands**: `create`, `delete`, `start`, `stop`, `status`

#### 6.2 Configuration Constants

| Constant | Current value | New value |
|----------|--------------|-----------|
| `CLUSTER_NAME` | `eve5` | `eve-realm` |
| `REGISTRY_NAME` | `eve5-registry.localhost` | `eve-realm-registry.localhost` |
| `REGISTRY_PORT` | `5100` | `5100` (unchanged) |
| `API_PORT` | `6550` | `6550` (unchanged) |
| `HTTP_PORT` | `30000` | `30000` (unchanged) |

#### 6.3 `create` Command

1. **Guard**: Checks if cluster already exists — exits with message if so
2. **Registry**: `k3d registry create` with port 5100. Ignores error if already exists (`|| true`)
3. **Cluster**: `k3d cluster create` with:
   - `--registry-use k3d-eve-realm-registry.localhost:5100` — connects local registry
   - `--api-port 6550` — Kubernetes API port
   - `--port 30000:30000@server:0` — maps NodePort 30000 to host
   - `--k3s-arg "--disable=traefik@server:0"` — disables default Traefik ingress
   - `--wait` — blocks until cluster is ready
4. **Output**: `kubectl cluster-info`, registry address, NodePort address, next steps

#### 6.4 `delete` Command

1. **Cluster**: `k3d cluster delete` (ignores not-found)
2. **Registry**: `k3d registry delete` (ignores not-found)
- Both use `|| true` for idempotency

#### 6.5 `start` / `stop` Commands

- `start`: `k3d cluster start` — resumes a stopped cluster (preserves state)
- `stop`: `k3d cluster stop` — pauses cluster without destroying it

#### 6.6 `status` Command

1. Lists k3d clusters
2. Lists k3d registries
3. If current kubectl context matches the cluster: lists pods and services in the namespace

#### 6.7 Design Notes

- **Traefik disabled**: The cluster uses NodePort for local access instead of Traefik.
  This is deliberate — the hub's NodePort Service exposes port 30000 directly
- **Single registry**: All plugin images share one registry at `k3d-eve-realm-registry.localhost:5100`
- **Idempotent**: `create` blocks on duplicate, `delete` ignores missing. `start`/`stop`
  are naturally idempotent via k3d

---

## Makefile Targets — Feature Inventory

### 7. Infra Makefile Targets

The following Makefile targets from the eve-cli monorepo are infra-owned. They will move
to the infra repo's Makefile, adapted for the new directory structure.

#### 7.1 `deploy-nats`

- **Source**: `Makefile:87-88`
- **Current**: `kubectl apply -f deploy/k8s/nats-deployment.yaml -f deploy/k8s/nats-service.yaml`
- **New**: `kubectl apply -f k8s/nats/`
- **Note**: Does not apply nats-configmap.yaml separately — this is a bug in the monorepo Makefile.
  The configmap is applied only via `deploy-local`. The infra Makefile must include it.

#### 7.2 `deploy-redis`

- **Source**: `Makefile:90-91`
- **Current**: `kubectl apply -f deploy/k8s/redis-deployment.yaml -f deploy/k8s/redis-service.yaml`
- **New**: `kubectl apply -f k8s/redis/`

#### 7.3 `deploy-infra`

- **Source**: `Makefile:93`
- **Current**: `deploy-nats deploy-redis` (delegates to sub-targets)
- **New**: Must also include namespace, configmap, and NATS configmap:
  ```
  kubectl apply -f k8s/namespace.yaml -f k8s/configmap.yaml
  kubectl apply -f k8s/nats/
  kubectl apply -f k8s/redis/
  ```

#### 7.4 `undeploy-infra`

- **Source**: `Makefile:95-97`
- **Current**: Deletes NATS and Redis manifests with `--ignore-not-found`
- **New**: Same pattern, adapted paths. Does NOT delete namespace (that would destroy all
  plugin deployments)

#### 7.5 `k3d-status`

- **Source**: `Makefile:136-144`
- **Current**: Lists pods, services, and recent events in the `eve5` namespace
- **New**: Same structure with `eve-realm` namespace

#### 7.6 `verify-cluster`

- **Source**: `Makefile:127-131`
- **Current sequence**:
  1. Delete previous verify job (ignore not-found)
  2. Sed `VERSION_PLACEHOLDER` and apply
  3. `kubectl wait --for=condition=complete` with 120s timeout
  4. On failure: print logs and exit 1
  5. On success: print logs
- **New**: Same pattern, adapted names

#### 7.7 `undeploy-local`

- **Source**: `Makefile:133-134`
- **Current**: `kubectl delete namespace eve5 --ignore-not-found`
- **New**: `kubectl delete namespace eve-realm --ignore-not-found`
- **Note**: Nuclear option — deletes everything. Useful for clean reset

#### 7.8 New Targets (not in eve-cli)

| Target | Purpose |
|--------|---------|
| `cluster-create` | Calls `scripts/k3d-cluster.sh create` |
| `cluster-delete` | Calls `scripts/k3d-cluster.sh delete` |
| `cluster-start` | Calls `scripts/k3d-cluster.sh start` |
| `cluster-stop` | Calls `scripts/k3d-cluster.sh stop` |
| `cluster-status` | Calls `scripts/k3d-cluster.sh status` |
| `deploy-all` | Calls `scripts/deploy-all.sh` — full orchestration |

---

## Deployment Orchestration

### 8. Deploy-All Script (`deploy-all.sh`) — NEW

This script does not exist in the eve-cli monorepo. The monorepo's `deploy-local` target
applies all manifests in a single `kubectl apply` invocation because all manifests live in
one directory. In the multi-repo setup, each repo owns its own manifests and must be deployed
in dependency order.

#### 8.1 Deployment Order (from HLD section 8)

```
1. eve-realm-infra      → namespace, configmap, NATS, Redis
2. eve-realm-hub        → frontend deployment + service
3. eve-realm-software   → plugin deployment + service
4. eve-realm-admin      → plugin deployment + service + configmap + secret
5. eve-realm-mcp        → MCP Server deployment + service
```

#### 8.2 Required Wait Points

The script must wait for readiness between dependency layers:

1. **After namespace**: Namespace must exist before any other resource
2. **After NATS + Redis**: Services must be ready before plugins that depend on them
3. **After hub + plugins**: MCP Server discovers plugins via NATS — plugins must be running

#### 8.3 Design Considerations

- **Cross-repo manifest access**: The deploy-all script needs to apply manifests from
  peer repos. Options: (a) peer repos are checked out as siblings, (b) pre-built manifest
  tarballs, (c) each repo deploys itself and deploy-all just calls `make deploy-local` in
  each repo
- **VERSION_PLACEHOLDER substitution**: Each repo's deployment manifest contains
  `VERSION_PLACEHOLDER` which must be replaced with that repo's `VERSION` file value. Each
  repo's version is independent
- **Partial deployment**: The script should support deploying just infra (`deploy-all infra`)
  or infra + hub (`deploy-all hub`) without requiring all plugins

---

## Rename Registry

All `eve5` → `eve-realm` renames required during extraction:

| Location | Old value | New value |
|----------|-----------|-----------|
| Namespace name | `eve5` | `eve-realm` |
| Namespace label | `app.kubernetes.io/part-of: eve5` | `app.kubernetes.io/part-of: eve-realm` |
| ConfigMap name | `eve5-config` | `eve-realm-config` |
| All env var keys | `EVE5_*` | `EVE_REALM_*` |
| Database names (DSN) | `eve5`, `eve5_control_plane` | `eve-realm`, `eve-realm_control_plane` |
| Database user (DSN) | `eve5` | `eve-realm` |
| Auth0 audience | `https://api.eve5.dev` | `https://api.eve-realm.dev` |
| Plugin service URL | `eve5-software.eve5.svc` | `eve-realm-software.eve-realm.svc` |
| NATS deployment name | `eve5-nats` | `eve-realm-nats` |
| NATS config name | `eve5-nats-config` | `eve-realm-nats-config` |
| NATS service DNS | `eve5-nats.eve5.svc` | `eve-realm-nats.eve-realm.svc` |
| NATS password value | `eve5nats` | `eve-realm-nats` |
| NATS browser token value | `eve5browser` | `eve-realm-browser` |
| NATS browser permission | `"eve5.ui.>"` | `"eve-realm.ui.>"` |
| Redis deployment name | `eve5-redis` | `eve-realm-redis` |
| Redis service DNS | `eve5-redis.eve5.svc` | `eve-realm-redis.eve-realm.svc` |
| Verify job name | `eve5-verify` | `eve-realm-verify` |
| Verify job image | `k3d-eve5-registry.localhost:5100/eve5` | `k3d-eve-realm-registry.localhost:5100/eve-realm-verify` |
| Verify binary | `/usr/local/bin/eve5-verify` | `/usr/local/bin/eve-realm-verify` |
| Cluster name (k3d) | `eve5` | `eve-realm` |
| Registry name (k3d) | `eve5-registry.localhost` | `eve-realm-registry.localhost` |
| Docker image prefix | `k3d-eve5-registry.localhost:5100/eve5` | `k3d-eve-realm-registry.localhost:5100/eve-realm-*` |
| Neo4j database | `eve5` | `eve-realm` |
| Neo4j password | `eve5realm` | `eve-realm` |

## Cross-Cutting Observations

1. **Infra is the foundation, not an application**: Unlike plugin repos, infra has no
   application code, no Docker build, and no binary. Its artifacts are YAML manifests and
   shell scripts. The Makefile orchestrates `kubectl apply`, not `go build`.

2. **ConfigMap is the single source of environment truth**: Every plugin consumes the
   shared ConfigMap via `envFrom`. Adding a new environment variable means editing
   one file in infra, not N plugin manifests. This centralisation is a key architectural
   benefit — but also a single point of failure if the ConfigMap is misconfigured.

3. **NATS two-tier auth is security-critical**: The browser user can ONLY subscribe to
   `eve-realm.ui.>` events and cannot publish. This prevents malicious browser code from
   injecting NATS messages. The pod user has full access. This boundary must be preserved
   exactly during rename.

4. **Redis is ephemeral by design**: No persistence, no auth, no maxmemory. Plugin registry
   data reconstructs via NATS heartbeats within 30 seconds of Redis restart. This is
   acceptable for local development but needs hardening for production.

5. **Verify job depends on a custom binary**: The current verify job requires an image
   with the `eve5-verify` binary. In the multi-repo setup, infra either needs its own
   Docker build pipeline (just for verify) or the verify job should be replaced with
   a script-based approach using standard tooling (`nats-cli`, `redis-cli`, `pg_isready`).

6. **Deploy-all is a new orchestration challenge**: The monorepo deploys everything from
   one directory with one command. The multi-repo setup requires cross-repo coordination
   with version-independent substitution and readiness gates between layers.

7. **NATS configmap has a bug in the monorepo Makefile**: The `deploy-nats` target applies
   only the deployment and service, not the configmap. The NATS configmap is applied as
   part of the broader `deploy-local` target but not as part of `deploy-nats`. The infra
   Makefile must fix this by including the configmap in the NATS deployment.

8. **No JetStream in current config**: The NATS configuration does not enable JetStream.
   The HLD mentions JetStream as a capability. If JetStream is needed, the NATS config
   must add `jetstream { store_dir: /data/nats, max_mem_store: 64MB }` and the deployment
   must add a persistent volume or emptyDir.

9. **Traefik is intentionally disabled**: The k3d cluster disables the default Traefik
   ingress controller. The hub is accessed directly via NodePort 30000. A proper Ingress
   resource will be a new addition to the infra repo.

## Suggested Extraction Order

Unlike the SDK (which has a deep dependency graph across Go packages), infra artifacts have
a flat dependency structure — manifests depend on the namespace existing, but are otherwise
independent. The extraction order is driven by deployment dependency, not build dependency.

```
Step 1: namespace + configmap + k3d script  (foundation — everything depends on these)
Step 2: NATS (configmap + deployment + service)  (depends on namespace + configmap)
Step 3: Redis (deployment + service)  (depends on namespace)
Step 4: verify job + Makefile  (depends on all services being defined)
Step 5: deploy-all orchestration + Ingress  (new artifacts — cross-repo coordination)
```

Steps 2 and 3 have no dependency on each other and can be extracted in parallel.
Step 5 contains only new artifacts (not from eve-cli) and requires design decisions
before implementation.

## Entity Creation Process

Eve-software entities describe what each infra component **will do** — not where the
manifests come from. The eve-cli source is an oracle for understanding configuration values,
resource limits, and service topology, but entities read as original infra specifications.
No references to extraction, porting, migration, or the source monorepo.

### Cadence: one architect session per extraction step

Each extraction step from the order above maps to one `/eve-software:architect` session.
The session produces the full set of entities needed to sprint-implement that step.

| Extraction step | Architect session scope |
|----------------|------------------------|
| Step 1 | Namespace, shared ConfigMap, k3d cluster script (foundation layer) |
| Step 2 | NATS messaging service (configmap, deployment, service, auth model) |
| Step 3 | Redis cache service (deployment, service) |
| Step 4 | Cluster verification job, Makefile targets |
| Step 5 | Deploy-all orchestration script, Ingress resource (new artifacts, design decisions) |

### Session workflow

For each step:

1. **Context loading** — Consult the eve-cli manifests and scripts to understand existing
   configuration, resource limits, health checks, and service topology. This is research
   input, not entity content.

2. **Requirements (REQs)** — Create requirements describing what the component provides
   as if designing it from scratch. Affirmative language only: "The NATS deployment provides
   a single-node messaging server with two-tier authentication..." — never "extracted from"
   or "ported from". Typical yield: 1–3 REQs per step.

3. **Scenarios (SCs)** — Derive scenarios from each REQ's acceptance criteria. Cover
   deploy success, service health, failure recovery, and idempotency. Typical yield:
   2–5 SCs per step.

4. **Decisions (ADRs)** — When a design question surfaces during discussion (e.g.,
   verify job strategy, JetStream enablement, Secrets migration), formalize it as an
   ADR. Only create when a decision is actually made — don't force ADRs.

5. **Sprint** — Group the step's entities into a sprint. Proceed through the standard
   pipeline: `spec → plan → implement`.

### Principles

- **Eve-cli is the oracle, not the spec**: Use it to avoid missing configuration details.
  The entities describe the infra as an original product.
- **Gradual, not bulk**: One step at a time. Never create entities for a step that
  hasn't been discussed in an architect session.
- **Forward-looking text**: Entities describe what WILL be built. No past tense, no
  migration language, no "previously in eve-cli".
- **Context-friendly**: Each session produces a bounded set of entities (3–8 per step)
  that fits comfortably in a single sprint without overloading agent context.

## Next Steps

1. **Import this plan as docproject research** (RES-01) for reference during documentation
2. **Start Step 1 architect session** — namespace, shared ConfigMap, k3d cluster script
   requirements, scenarios, and decisions
3. **Formalize cross-cutting decisions** as ADRs when they surface during sessions
   (verify job strategy, deploy-all cross-repo access, JetStream enablement, Ingress
   resource design, Secrets migration path)
4. **Create docproject definitions and sections** alongside or after each sprint
5. **Iterate** — each completed sprint validates the process before the next step begins
