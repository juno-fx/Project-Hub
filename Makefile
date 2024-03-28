# vars
PROJECT="project-hub"

# targets
cluster:
	@kind create cluster --name $(PROJECT) --config juno/kind.yaml || echo "Cluster already exists..."
	@echo "Waiting for cluster to settle..."
	@sleep 5
	@kubectl wait --namespace kube-system \
		--for=condition=ready pod \
		--selector=component=kube-apiserver \
		--timeout=90s > /dev/null > /dev/null 2>&1
	@echo "Waiting for kindnet..."
	@sleep 10
	@kubectl wait --namespace kube-system \
		--for=condition=ready pod \
		--selector=app=kindnet \
		--timeout=90s > /dev/null > /dev/null 2>&1

down:
	@kind delete cluster --name $(PROJECT)

# testing
ref-test: down cluster ref-dependencies
test: down cluster dependencies

# dependencies
ref-dependencies: argo ingress project-hub-ref argo-connect
dependencies: argo ingress project-hub argo-connect

ingress:
	@echo "Installing NGINX Ingress..."
	@kubectl apply -f juno/k8s/ > /dev/null 2>&1

argo:
	@echo "Installing ArgoCD..."
	@kubectl create namespace argocd > /dev/null 2>&1 || echo " - Namespace argocd already exists"
	@kubectl -n argocd apply -f  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null 2>&1
	@echo "Waiting for Argo..."
	@sleep 15
	@kubectl wait --namespace argocd \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/name=argocd-server \
		--timeout=90s > /dev/null 2>&1

project-hub-ref:
	@echo "Installing Project Hub..."
	@kubectl apply -f juno/project-hub.yaml > /dev/null 2>&1

project-hub:
	@echo "Installing Project Hub..."
	@helm install -f juno/test-values.yaml $(PROJECT) ./ --wait > /dev/null 2>&1

argo-connect:
	@echo "Waiting for ingress to be ready..."
	@sleep 30
	@kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s > /dev/null 2>&1
	@echo
	@echo "ArgoCD URL:"
	@echo "http://localhost/"
