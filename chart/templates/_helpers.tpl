{{/*
Fails with a message naming the values key when a list is empty: `required`
accepts an empty list.
*/}}
{{- define "homelab-argocd.requireList" -}}
{{- if not .value -}}
  {{- fail (printf "homelab-argocd: %s must list at least one entry" .path) -}}
{{- end -}}
{{- end -}}

{{/*
Overlay repository URL, required by the ApplicationSet.
*/}}
{{- define "homelab-argocd.overlayRepoURL" -}}
{{- required "homelab-argocd: overlay.repoURL is required" .Values.overlay.repoURL -}}
{{- end -}}
