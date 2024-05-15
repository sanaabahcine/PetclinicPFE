{{- define "petclinic.name" -}}
petclinic
{{- end -}}

{{- define "petclinic.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "petclinic.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "petclinic.labels" -}}
app.kubernetes.io/name: {{ include "petclinic.name" . }}
helm.sh/chart: {{ include "petclinic.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
