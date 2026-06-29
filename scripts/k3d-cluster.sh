#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="eve-realm"
REGISTRY_NAME="eve-realm-registry.localhost"
REGISTRY_PORT=5100
API_PORT=6550
HTTP_PORT=30000
GRPC_PORT=30051

# Colored output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==>${RESET} $*"; }
success() { echo -e "${GREEN}==>${RESET} $*"; }
warn()    { echo -e "${YELLOW}Warning:${RESET} $*"; }
error()   { echo -e "${RED}Error:${RESET} $*" >&2; }

NODEPORTS=("${HTTP_PORT}" "${GRPC_PORT}")

LIMA_SSH_SOCK="${HOME}/Library/Application Support/rancher-desktop/lima/0/ssh.sock"

usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $0 <command>

${BOLD}Commands:${RESET}
  create    Create the eve-realm k3d cluster with a local registry
  delete    Delete the eve-realm k3d cluster and registry
  start     Start a stopped eve-realm cluster
  stop      Stop the eve-realm cluster (preserves state)
  status    Show cluster and registry status
EOF
}

ensure_port_forwarding() {
  if [[ ! -S "${LIMA_SSH_SOCK}" ]]; then
    return 0
  fi

  info "Verifying host port forwarding (Lima/Rancher Desktop)"
  local failed=0
  for port in "${NODEPORTS[@]}"; do
    if nc -z -w 2 localhost "${port}" 2>/dev/null; then
      success "  port ${port} — reachable"
    else
      warn "  port ${port} — not reachable, forcing SSH tunnel"
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -S "${LIMA_SSH_SOCK}" \
        -O forward -L "0.0.0.0:${port}:localhost:${port}" \
        lima-rancher-desktop 2>/dev/null

      if nc -z -w 2 localhost "${port}" 2>/dev/null; then
        success "  port ${port} — tunnel established"
      else
        error "  port ${port} — tunnel failed, port still unreachable"
        failed=1
      fi
    fi
  done
  if [[ "${failed}" -eq 1 ]]; then
    warn "Some ports could not be forwarded. Try restarting Rancher Desktop."
  fi
}

create_cluster() {
  if k3d cluster list 2>/dev/null | grep -q "^${CLUSTER_NAME} "; then
    error "Cluster '${CLUSTER_NAME}' already exists."
    echo "  Use '$0 start' to start it if it is stopped."
    exit 1
  fi

  info "Creating registry k3d-${REGISTRY_NAME}:${REGISTRY_PORT}"
  k3d registry create "${REGISTRY_NAME}" --port "${REGISTRY_PORT}" 2>/dev/null || true

  info "Creating cluster ${CLUSTER_NAME}"
  k3d cluster create "${CLUSTER_NAME}" \
    --registry-use "k3d-${REGISTRY_NAME}:${REGISTRY_PORT}" \
    --api-port "${API_PORT}" \
    --port "${HTTP_PORT}:30000@server:0" \
    --port "${GRPC_PORT}:30051@server:0" \
    --k3s-arg "--disable=traefik@server:0" \
    --wait

  success "Cluster ready"
  kubectl cluster-info --context "k3d-${CLUSTER_NAME}"
  echo ""
  echo -e "  ${BOLD}Registry:${RESET}  k3d-${REGISTRY_NAME}:${REGISTRY_PORT}"
  echo -e "  ${BOLD}HTTP:${RESET}      localhost:${HTTP_PORT}"
  echo -e "  ${BOLD}gRPC:${RESET}      localhost:${GRPC_PORT}"
  echo ""

  ensure_port_forwarding

  echo -e "${BOLD}Next steps:${RESET}"
  echo "  make deploy          # apply namespace, configmap, NATS, Redis manifests"
  echo "  make deploy-verify   # run verification job to confirm cluster health"
}

delete_cluster() {
  info "Deleting cluster ${CLUSTER_NAME}"
  k3d cluster delete "${CLUSTER_NAME}" 2>/dev/null || true

  info "Deleting registry k3d-${REGISTRY_NAME}"
  k3d registry delete "k3d-${REGISTRY_NAME}" 2>/dev/null || true

  success "Done"
}

start_cluster() {
  info "Starting cluster ${CLUSTER_NAME}"
  k3d cluster start "${CLUSTER_NAME}"
  success "Cluster started"
  ensure_port_forwarding
}

stop_cluster() {
  info "Stopping cluster ${CLUSTER_NAME}"
  k3d cluster stop "${CLUSTER_NAME}"
  success "Cluster stopped (state preserved)"
}

show_status() {
  echo -e "${BOLD}=== Clusters ===${RESET}"
  k3d cluster list 2>/dev/null || echo "(none)"
  echo ""

  echo -e "${BOLD}=== Registries ===${RESET}"
  k3d registry list 2>/dev/null || echo "(none)"
  echo ""

  if kubectl config current-context 2>/dev/null | grep -q "k3d-${CLUSTER_NAME}"; then
    echo -e "${BOLD}=== Pods (eve-realm namespace) ===${RESET}"
    kubectl get pods -n eve-realm 2>/dev/null || echo "(namespace not found)"
    echo ""

    echo -e "${BOLD}=== Services (eve-realm namespace) ===${RESET}"
    kubectl get svc -n eve-realm 2>/dev/null || echo "(namespace not found)"
  else
    warn "kubectl context is not 'k3d-${CLUSTER_NAME}' — skipping pod and service queries"
  fi
}

case "${1:-}" in
  create) create_cluster ;;
  delete) delete_cluster ;;
  start)  start_cluster ;;
  stop)   stop_cluster ;;
  status) show_status ;;
  *)      usage; exit 1 ;;
esac
