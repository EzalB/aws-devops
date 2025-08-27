{{- define "obm.appName" -}}
{{- .Values.appName | default "todo" -}}
{{- end -}}

{{- define "obm.branchName" -}}
{{- .Values.branchName | default "main" -}}
{{- end -}}

{{- define "obm.labels" -}}
labels:
  app: {{ include "obm.appName" . }}
  {{- range $key, $value := .Values.customLabels }}
  {{ $key }}: {{ $value }}
  {{- end }}
{{- end -}}

{{- define "obm.fullImageName" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
