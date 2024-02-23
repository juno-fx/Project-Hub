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

### ArgoCD Application

Ideally, you will use an Application in ArgoCD to deploy the Project Hub. Below is an example of how to set one up.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: project-hub
  namespace: argocd
spec:
  project: <your project>
  destination:
    server: <target cluster>
    namespace: argocd
  
  # We use the multi source approach to allow for the use of a private values repo
  # https://argo-cd.readthedocs.io/en/stable/user-guide/multiple_sources/
  sources:
    - path: .
      repoURL: https://github.com/juno-fx/Project-Hub.git
      targetRevision: <the version of Project Hub you want to use>
      helm:
        valueFiles:
          - $values/projects.yaml

    - repoURL: https://<your values repo>.git
      targetRevision: <branch>
      ref: values
```

Once this completes, you should have a dedicated [vcluster](https://vcluster.com/) for each project. This will allow for 
the isolation of each project and the ability to scale them independently. From here, you can begin to deploy other Juno
services to the project cluster using ApplicationSets in ArgoCD.