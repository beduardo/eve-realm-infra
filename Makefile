.PHONY: cluster-create cluster-delete cluster-start cluster-stop cluster-status deploy bump-patch bump-minor bump-major undeploy undeploy-local k3d-status

cluster-create:
	./scripts/k3d-cluster.sh create

cluster-delete:
	./scripts/k3d-cluster.sh delete

cluster-start:
	./scripts/k3d-cluster.sh start

cluster-stop:
	./scripts/k3d-cluster.sh stop

cluster-status:
	./scripts/k3d-cluster.sh status

deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	[ -d k8s/nats ] && kubectl apply -f k8s/nats/ || true
	[ -d k8s/redis ] && kubectl apply -f k8s/redis/ || true

undeploy:
	[ -d k8s/nats ] && kubectl delete -f k8s/nats/ --ignore-not-found || true
	[ -d k8s/redis ] && kubectl delete -f k8s/redis/ --ignore-not-found || true

undeploy-local:
	kubectl delete namespace eve-realm --ignore-not-found

k3d-status:
	kubectl get pods -n eve-realm
	kubectl get services -n eve-realm
	kubectl get events -n eve-realm --sort-by='.lastTimestamp' | tail -20

bump-patch:
	@test -f VERSION || (echo "ERROR: VERSION file not found" >&2 && exit 1)
	@read v < VERSION && \
	  major=$$(echo $$v | awk -F. '{print $$1}') && \
	  minor=$$(echo $$v | awk -F. '{print $$2}') && \
	  patch=$$(echo $$v | awk -F. '{print $$3}') && \
	  patch=$$((patch + 1)) && \
	  echo "$${major}.$${minor}.$${patch}" > VERSION && \
	  echo "Version bumped to $${major}.$${minor}.$${patch}"

bump-minor:
	@test -f VERSION || (echo "ERROR: VERSION file not found" >&2 && exit 1)
	@read v < VERSION && \
	  major=$$(echo $$v | awk -F. '{print $$1}') && \
	  minor=$$(echo $$v | awk -F. '{print $$2}') && \
	  minor=$$((minor + 1)) && \
	  echo "$${major}.$${minor}.0" > VERSION && \
	  echo "Version bumped to $${major}.$${minor}.0"

bump-major:
	@test -f VERSION || (echo "ERROR: VERSION file not found" >&2 && exit 1)
	@read v < VERSION && \
	  major=$$(echo $$v | awk -F. '{print $$1}') && \
	  major=$$((major + 1)) && \
	  echo "$${major}.0.0" > VERSION && \
	  echo "Version bumped to $${major}.0.0"
