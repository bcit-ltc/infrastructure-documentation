# {{/*
# securityContext for the pod level.
# */}}
# {{- define "securityContext.pod" -}}
#   {{- if .Values.securityContext.pod }}
#       securityContext:
#         {{- $tp := typeOf .Values.securityContext.pod }}
#         {{- if eq $tp "string" }}
#           {{- tpl .Values.securityContext.pod . | nindent 8 }}
#         {{- else }}
#           {{- toYaml .Values.securityContext.pod | nindent 8 }}
#         {{- end }}
#   {{- else if not .Values.global.openshift }}
#       securityContext:
#         runAsNonRoot: true
#         runAsGroup: {{ .Values.gid | default 1000 }}
#         runAsUser: {{ .Values.uid | default 100 }}
#         fsGroup: {{ .Values.gid | default 1000 }}
#   {{- end }}
# {{- end -}}

# {{/*
# securityContext for the container level.
# */}}
# {{- define "securityContext.container" -}}
#   {{- if .Values.securityContext.container}}
#           securityContext:
#             {{- $tp := typeOf .Values.securityContext.container }}
#             {{- if eq $tp "string" }}
#               {{- tpl .Values.securityContext.container . | nindent 12 }}
#             {{- else }}
#               {{- toYaml .Values.securityContext.container | nindent 12 }}
#             {{- end }}
#   {{- else if not .Values.global.openshift }}
#           securityContext:
#             allowPrivilegeEscalation: false
#             capabilities:
#               drop:
#                 - ALL
#   {{- end }}
# {{- end -}}