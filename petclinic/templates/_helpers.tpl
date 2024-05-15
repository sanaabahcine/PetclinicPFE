{{- define "petclinic.name" -}}
petclinic
{{- end -}}

{{- define "petclinic.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "petclinic.name" .) | trunc 63 | trimSuffix "-" | replace "petclinic-" "" -}}
{{- end -}}

{{- define "petclinic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version -}}
{{- end -}}

{{- define "petclinic.labels" -}}
app.kubernetes.io/name: petclinic
helm.sh/chart: {{ include "petclinic.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
