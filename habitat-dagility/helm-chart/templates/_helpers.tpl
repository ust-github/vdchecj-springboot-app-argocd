{{/*
Expand the name of the chart.
*/}}
{{- define "microservice.name" -}}
{{- default .Release.Name .Values.deployment.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "microservice.fullname" }}
{{- if .Values.deployment.fullnameOverride -}}
{{- .Values.deployment.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Release.Name .Values.deployment.nameOverride | trunc 63 | trimSuffix "-"}}
{{- printf "%s-%s"  .Chart.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Create the labels of microservice application
*/}}
{{- define "microservice.labels" }}
app.kubernetes.io/name: {{ include "microservice.name" . | quote}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- if .Values.labels }}
{{- range $key, $val := .Values.labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define  initContainers
*/}}
{{- define "microservice.initContainers" }}
{{- if .Values.deployment.initContainers.enabled }}
{{- with .Values.deployment.initContainers.values }}
initContainers:
  - name: {{ .name }}
    image: {{ .image }}
    command:
    {{- range .command }}
    - {{ . }}
    {{- end }}
    args:
    {{- range .args }}
    - {{ . }}
    {{- end }}
    imagePullPolicy: Always
    volumeMounts:
      - name: applogs
        mountPath: /deployments
    {{- if .resources.enabled }}
    resources:
    {{- with .resources }}
      requests:
        cpu: {{ .requests.cpu }}
        memory: {{ .requests.memory }}
      limits:
        cpu: {{ .limits.cpu }}
        memory: {{ .limits.memory }}
    {{- end }}
    {{- end }}
    {{- if .securityContext.enabled }}
    securityContext:
    {{- with .securityContext }}
      readOnlyRootFilesystem: {{ .readOnlyRootFilesystem }}
      allowPrivilegeEscalation: {{ .allowPrivilegeEscalation }}
      runAsNonRoot: {{ .runAsNonRoot }}
      runAsUser: {{ .runAsUser }}
      runAsGroup: {{ .runAsGroup }}
     {{- end }}
     {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define the strategy of deployment
*/}}
{{- define "microservice.strategy" }}
strategy:
  type: {{ .Values.deployment.updateStrategy.type | default "RollingUpdate" }}
  {{- if eq .Values.deployment.updateStrategy.type "RollingUpdate"}}
  rollingUpdate:
    maxSurge: {{ .Values.deployment.updateStrategy.maxReplicas | default `100%` }}
    maxUnavailable: {{ .Values.deployment.updateStrategy.maxUnavailable | default 0 }}
  {{- end }}
{{- end }}

{{/*
Create the podAnnotations
*/}}
{{- define "microservice.podAnnotations" }}
{{- if .Values.deployment.podAnnotations }}
annotations:
  {{- range $key, $val := .Values.deployment.podAnnotations  }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Create the podSecurityContext to use
*/}}
{{- define "microservice.podSecurityContext" }}
{{- if .Values.deployment.podSecurityContext.enabled | default false }}
securityContext:
{{ toYaml .Values.deployment.podSecurityContext.values | indent 2 }}
{{- end }}
{{- end }}


{{/*
Create the AGRS to use
*/}}
{{- define "microservice.args" }}
{{- if .Values.deployment.args }}
args:
{{- range .Values.deployment.args  }}
- {{ . }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create the livenessProbe to use
*/}}
{{- define "microservice.livenessProbe" }}
{{- if .Values.deployment.livenessProbe }}
livenessProbe:
  httpGet:
    path: {{ .Values.deployment.livenessProbe.httpGet.path }}
    port: {{ .Values.deployment.livenessProbe.httpGet.port }}
{{- if .Values.deployment.livenessProbe.initialDelaySeconds }}
  initialDelaySeconds: {{ .Values.deployment.livenessProbe.initialDelaySeconds | default 30 }}
{{- end }}
{{- if .Values.deployment.livenessProbe.failureThreshold }}
  failureThreshold: {{ .Values.deployment.livenessProbe.failureThreshold | default 3 }}
{{- end }}
{{- if .Values.deployment.livenessProbe.periodSeconds }}
  periodSeconds: {{ .Values.deployment.livenessProbe.periodSeconds | default 10 }}
{{- end }}
{{- if .Values.deployment.livenessProbe.timeoutSeconds }}
  timeoutSeconds: {{ .Values.deployment.livenessProbe.timeoutSeconds | default 5 }}
{{- end }}     
{{- end }}
{{- end }}


{{/*
Create the readinessProbe to use
*/}}
{{- define "microservice.readinessProbe" }}
{{- if .Values.deployment.readinessProbe }}
readinessProbe:
  httpGet:
    path: {{ .Values.deployment.readinessProbe.httpGet.path }}
    port: {{ .Values.deployment.readinessProbe.httpGet.port }}
{{- if .Values.deployment.readinessProbe.initialDelaySeconds }}
  initialDelaySeconds: {{ .Values.deployment.readinessProbe.initialDelaySeconds | default 30 }}
{{- end }}
{{- if .Values.deployment.readinessProbe.failureThreshold }}
  failureThreshold: {{ .Values.deployment.readinessProbe.failureThreshold | default 3 }}
{{- end }}
{{- if .Values.deployment.readinessProbe.periodSeconds }}
  periodSeconds: {{ .Values.deployment.readinessProbe.periodSeconds | default 10 }}
{{- end }}
{{- if .Values.deployment.readinessProbe.timeoutSeconds }}
  timeoutSeconds: {{ .Values.deployment.readinessProbe.timeoutSeconds | default 5 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the securityContext of container to use
*/}}
{{- define "microservice.securityContext" }}
{{- if .Values.deployment.securityContext.enabled | default false }}
securityContext:
{{ toYaml .Values.deployment.securityContext.values | indent 2 }}
{{- end }}
{{- end }}

{{/*
define the nodeSelector  to use
*/}}
{{- define "microservice.nodeSelector" }}
{{- if .Values.nodeSelector.enabled | default false }}
{{- with .Values.nodeSelector.values }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define the affinity to use
*/}}range ,  := .
{{- define "microservice.affinity" }}
{{- if .Values.affinity.enabled | default false }}
{{- with .Values.affinity.values }}
affinity:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}
{{- end }}



{{/*
define the environmental variables to use */}}
{{- define "microservice.env" }}
{{- if .Values.env }}
env:
{{- range $key, $val := .Values.env }}
- name: {{ $key | upper }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define the resources to use
*/}}
{{- define "microservice.resources" }}
{{- if .Values.deployment.resources }}
resources:
{{ toYaml .Values.deployment.resources | indent 2 }}
{{- end }}
{{- end }}

{{/*
define the  extraVolumeMounts to use
*/}}
{{- define "microservice.extraVolumeMounts" }}
{{- if .Values.extraVolumes }}
{{- range .Values.extraVolumes}}
- name: {{ .name }}
  mountPath: {{ .path }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define the  extraVolumes to use
*/}}
{{- define "microservice.extraVolumes" }}
{{- range .Values.extraVolumes }}
- name: {{ .name }}
{{- if .values }}
{{ toYaml .values | indent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the annotations of the service account to use
*/}}

{{- define "microservice.serviceAnnotations" }}
{{- if and (.Values.service.annotations) ( eq .Values.service.type "LoadBalancer" ) }}
annotations:
{{ toYaml .Values.service.annotations | indent 2 }}
{{- end }}
{{- end }}


{{/*
create the serviceaccount name to use
*/}}
{{- define "microservice.serviceAccount" }}
{{- if .Values.managedServiceAccount | default false  }}
{{-  .Values.managedServiceAccount.serviceAccount | default "svc-account" -}}
{{- else }}
{{ template "microservice.fullname" . }}
{{- end -}}
{{- end }}



{{- define "microservice.configdata" }}
{{- if .Values.configMap.values }}
{{ .Values.configMap.configMapFileName }}: |
{{- if eq .Values.configMap.jsonfile  true  }}
  {{- .Values.configMap.values | nindent 4 }}
{{- else }}
{{- range $key, $val := .Values.configMap.values }}
  {{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}


{{/*
define the secret  to use
*/}}
{{- define "microservice.secret" }}
{{- if .Values.secret.values }}
{{- range $key, $val := .Values.secret.values }}
{{ $key }}: {{ $val | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{/*
create the ingressAnnotations to use
*/}}
{{- define "microservice.ingressAnnotations" }}
{{- if .Values.ingress.annotations }}
annotations:
{{ toYaml .Values.ingress.annotations | indent 2 }}
{{- end }}
{{- end }}


