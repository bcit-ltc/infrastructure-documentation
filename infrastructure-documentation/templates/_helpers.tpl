{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" | lower -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name. Everything is lowercased.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride | lower -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}



{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "app.resources" -}}
  {{- if .Values.resources -}}
          resources:
{{ toYaml .Values.resources | indent 12}}
  {{ end }}
{{- end -}}

{{/*
Sets the deployment update strategy
*/}}
{{- define "app.strategy" -}}
  {{- if .Values.strategy }}
  strategy:
  {{- $tp := typeOf .Values.strategy }}
  {{- if eq $tp "string" }}
    {{ tpl .Values.strategy . | nindent 4 | trim }}
  {{- else }}
    {{- toYaml .Values.strategy | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end -}}

{{/*
Configure ingress
*/}}
{{- define "app.ingress" -}}
  {{- if .Values.ingress.create }}
  ingress:
    enabled: true
    annotations: {{- toYaml .Values.ingress.annotations | nindent 4 }}
    hosts:
      - host: {{ .Values.ingress.host | quote }}
        paths:
          - /
    tls:
      - secretName: {{ .Values.ingress.tlsSecret | quote }}
        hosts:
          - {{ .Values.ingress.host | quote }}
  {{- end }}
{{- end -}}
