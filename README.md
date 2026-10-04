# homelab-argocd

Generic Helm chart for an ArgoCD app-of-apps, driven by one `app.yaml` per
application in a private overlay repository.

```
overlay repository                            this chart (rendered by root)
├── bootstrap/root.yaml ──► Application root ─┬─► AppProject bootstrap  (ArgoCD objects only)
├── argocd/values.yaml  ──────────────────────┤   AppProject apps       (no raw Secret, denied namespaces)
└── apps/<name>/                              ├─► ApplicationSet apps   (git files generator)
    ├── app.yaml   ─────────────────────────────►   └─► Application <name>: chart + values + addons/
    ├── values.yaml                           ├─► repository declarations
    └── addons/                               └─► repo-creds ExternalSecrets
```

## What it enforces

| Object | Guarantee |
|---|---|
| ApplicationSet | `missingkey=error` (a field missing from an `app.yaml` fails); `preserveResourcesOnDeletion` (removing a directory deletes nothing); automated sync opt-in per application |
| AppProject `apps` | no raw `Secret` (secrets come from External Secrets); no destination in denied namespaces; `Namespace` as the only cluster-scoped kind |
| AppProject `bootstrap` | ArgoCD objects in the ArgoCD namespace only |
| AppProjects, credentials | `Prune=false,Delete=false`: never deleted by a sync |
| Credentials | ExternalSecrets only: no token in Git |

## Usage

1. Copy [values.EXAMPLE.yaml](values.EXAMPLE.yaml) to your overlay (for
   instance `argocd/values.yaml`) and adapt it.
2. Add a `root` Application to your overlay and apply it once by hand:

   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: root
     namespace: argocd
   spec:
     project: bootstrap
     sources:
       - repoURL: https://github.com/Damien-Petit-Thomas/homelab-argocd.git
         targetRevision: v0.1.0          # a release tag, never a branch
         path: chart
         helm:
           valueFiles:
             - $overlay/argocd/values.yaml
       - repoURL: https://git.example.org/me/homelab-argocd-overlay.git
         targetRevision: main
         ref: overlay
       - repoURL: https://git.example.org/me/homelab-argocd-overlay.git
         targetRevision: main
         path: bootstrap                 # root.yaml: root manages itself
     destination:
       server: https://kubernetes.default.svc
       namespace: argocd
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   ```
3. Describe each application in `apps/<name>/app.yaml`
   ([schema](schemas/app.schema.json)):

   ```yaml
   namespace: finance
   chart:
     repoURL: ghcr.io/bjw-s-labs/helm     # OCI: no oci:// scheme
     name: app-template
     version: 5.2.1                       # exact version
   autoSync: false                        # first sync reviewed by hand
   ```

The chart only renders ArgoCD's configuration: ArgoCD itself, its
repository access to the overlay and the External Secrets Operator are
installed beforehand (they are the path to fixing a broken configuration, so
they are not managed by it).

## Values

Documented in [chart/values.yaml](chart/values.yaml), validated by
[chart/values.schema.json](chart/values.schema.json).

## Decisions

[Architecture decision records](docs/adr/).

## License

[Apache-2.0](LICENSE)
