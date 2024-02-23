# vars
PY="python3.8"
VENV="venv/bin"
PIP="$(VENV)/pip3"
PROJECT="project-hub"

# targets
cluster:
	@kind create cluster --name $(PROJECT) || echo "Cluster already exists..."

down:
	@kind delete cluster --name $(PROJECT)

# testing
test: down cluster
	@echo "Tests... Cluster will be taken down after"
	@helm install $(PROJECT) ./ --wait
