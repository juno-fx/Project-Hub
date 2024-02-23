<br />
<p align="center">
    <img src="https://avatars.githubusercontent.com/u/9037579?v=4"/>
    <h3 align="center">Project Hub</h3>
    <p align="center">
        Manages the creation of project clusters via Helm and ArgoCD.
    </p>
</p>

## Dependencies

- [Juno Cluster Builder](https://github.com/juno-fx/Cluster-Builder)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)

## Usage

The Project Hub is a tool that allows for the creation of project clusters. It does this by deploying the [Juno Cluster Builder](https://github.com/juno-fx/Cluster-Builder).
This can be installed using [Helm](https://helm.sh/) but using a GitOps platform like [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) is recommended.

```yaml
image: aldmbmtl/cluster-builder:v0.0.1    # name of the container registry to pull the Cluster-Builder from
namespace: argocd                         # namespace to deploy the Cluster-Builder to. Needs to be the same as where Argo is

projects:
  - code:                                 # name, this is what it will be called in ArgoCD
    active:                               # active, specifies it the project should be deployed or "put to sleep"
    private:                              # private, allows for NetworkPolicies to be created to isolate the project
                                          #   from external traffic. Essentially disabling the internet and all possible
                                          #   project cross talk.
```