{{/*
ApplicationSet generating one Application per <appsDir>/<name>/app.yaml in the
overlay, in the given project. Used for the applications and platform tiers.
Call: include "homelab-argocd.applicationSet" (dict "context" $ "name" ...
      "project" ... "appsDir" ...)
*/}}
{{- define "homelab-argocd.applicationSet" -}}
{{- $ctx := .context -}}
{{- $overlay := include "homelab-argocd.overlayRepoURL" $ctx -}}
{{- /*
The ApplicationSet's own Go templates ({{ .path.basename }}, ...) must reach
ArgoCD untouched: they are written as Helm string literals, {{`{{ ... }}`}}.
*/}}
# One Application per <appsDir>/<name>/app.yaml. Adding a service = adding a
# directory.
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: {{ .name }}
  namespace: {{ $ctx.Values.argocdNamespace }}
spec:
  goTemplate: true
  # A field missing from an app.yaml is an error, not an empty string.
  goTemplateOptions: ["missingkey=error"]
  syncPolicy:
    # Removing a directory must never delete the service's resources.
    preserveResourcesOnDeletion: {{ $ctx.Values.applicationSet.preserveResourcesOnDeletion }}
  generators:
    - git:
        repoURL: {{ $overlay }}
        revision: {{ $ctx.Values.overlay.revision }}
        files:
          - path: "{{ .appsDir }}/*/app.yaml"
  # Automated sync is opt-in: a new app starts with autoSync: false, its first
  # sync is reviewed and triggered by hand, then it is switched to true.
  templatePatch: |
    {{`{{- if .autoSync }}`}}
    spec:
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
    {{`{{- end }}`}}
  template:
    metadata:
      name: '{{`{{ .path.basename }}`}}'
    spec:
      project: {{ .project }}
      sources:
        - repoURL: '{{`{{ .chart.repoURL }}`}}'
          chart: '{{`{{ .chart.name }}`}}'
          targetRevision: '{{`{{ .chart.version }}`}}'
          helm:
            releaseName: '{{`{{ .path.basename }}`}}'
            valueFiles:
              - '$overlay/{{`{{ .path.path }}`}}/values.yaml'
        - repoURL: {{ $overlay }}
          targetRevision: {{ $ctx.Values.overlay.revision }}
          ref: overlay
        - repoURL: {{ $overlay }}
          targetRevision: {{ $ctx.Values.overlay.revision }}
          path: '{{`{{ .path.path }}`}}/addons'
      destination:
        server: {{ $ctx.Values.destinationServer }}
        namespace: '{{`{{ .namespace }}`}}'
{{- end -}}
