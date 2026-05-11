{{- define "fastapi-microservices.name" -}}
fastapi-microservices
{{- end }}

{{- define "fastapi-microservices.fullname" -}}
{{ .Release.Name }}
{{- end }}