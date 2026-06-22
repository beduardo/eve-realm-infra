---
content_hash: 22283e9c6fc9f46998c6f652573fd9d079e0408deb402326981ba718c4e6e0b8
created: "2026-06-22"
id: REQ-001
priority: high
related_adrs: []
related_changes: []
related_scenarios:
    - SC-001
    - SC-002
related_testcases: []
related_userstories: []
source: manual
status: implemented
tags:
    - namespace
    - foundation
    - k8s
title: Eve Realm Namespace
updated: "2026-06-22"
---

# REQ-001: Eve Realm Namespace

## Description

The infra provides the `eve-realm` Kubernetes namespace as the tenant boundary for the
entire platform. All infrastructure services (NATS, Redis), the hub, and all plugins are
deployed into this namespace. The namespace manifest is the first resource applied in the
deployment chain — every other manifest depends on it.

## Acceptance Criteria

1. The manifest defines a `Namespace` resource with `apiVersion: v1` and `metadata.name: eve-realm`
2. The namespace includes the label `app.kubernetes.io/part-of: eve-realm`
3. No other metadata, annotations, or labels are defined beyond name and the single label
4. The manifest is idempotent — `kubectl apply` can be re-run without error or state change
5. The namespace is applied before any other manifest in the deployment chain

## Target Path

`k8s/namespace.yaml`
