{{/*
Expand the name of the chart.
*/}}
{{- define "my-blog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "my-blog.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-blog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-blog.labels" -}}
helm.sh/chart: {{ include "my-blog.chart" . }}
{{ include "my-blog.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-blog.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-blog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
WordPress specific labels
*/}}
{{- define "my-blog.wordpress.labels" -}}
{{ include "my-blog.labels" . }}
app.kubernetes.io/component: wordpress
{{- end }}

{{/*
WordPress selector labels
*/}}
{{- define "my-blog.wordpress.selectorLabels" -}}
{{ include "my-blog.selectorLabels" . }}
app.kubernetes.io/component: wordpress
{{- end }}

{{/*
MariaDB specific labels
*/}}
{{- define "my-blog.mariadb.labels" -}}
{{ include "my-blog.labels" . }}
app.kubernetes.io/component: mariadb
{{- end }}

{{/*
MariaDB selector labels
*/}}
{{- define "my-blog.mariadb.selectorLabels" -}}
{{ include "my-blog.selectorLabels" . }}
app.kubernetes.io/component: mariadb
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-blog.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-blog.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the WordPress full name
*/}}
{{- define "my-blog.wordpress.fullname" -}}
{{- printf "%s-wordpress" (include "my-blog.fullname" .) }}
{{- end }}

{{/*
Create the MariaDB full name
*/}}
{{- define "my-blog.mariadb.fullname" -}}
{{- printf "%s-mariadb" (include "my-blog.fullname" .) }}
{{- end }}

{{/*
Create the WordPress secret name
*/}}
{{- define "my-blog.wordpress.secretName" -}}
{{- if .Values.wordpress.auth.existingSecret }}
{{- .Values.wordpress.auth.existingSecret }}
{{- else }}
{{- printf "%s-wordpress" (include "my-blog.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the MariaDB secret name
*/}}
{{- define "my-blog.mariadb.secretName" -}}
{{- if .Values.mariadb.auth.existingSecret }}
{{- .Values.mariadb.auth.existingSecret }}
{{- else }}
{{- printf "%s-mariadb" (include "my-blog.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the proper WordPress image name
*/}}
{{- define "my-blog.wordpress.image" -}}
{{- $registryName := .Values.wordpress.image.registry -}}
{{- $repositoryName := .Values.wordpress.image.repository -}}
{{- $tag := .Values.wordpress.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
  {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- if $registryName }}
  {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
  {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end }}

{{/*
Return the proper MariaDB image name
*/}}
{{- define "my-blog.mariadb.image" -}}
{{- $registryName := .Values.mariadb.image.registry -}}
{{- $repositoryName := .Values.mariadb.image.repository -}}
{{- $tag := .Values.mariadb.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
  {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- if $registryName }}
  {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
  {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end }}

{{/*
Return the proper Storage Class
*/}}
{{- define "my-blog.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else if .Values.wordpress.persistence.storageClass }}
{{- .Values.wordpress.persistence.storageClass }}
{{- end }}
{{- end }}

{{/*
Return the proper MariaDB Storage Class
*/}}
{{- define "my-blog.mariadb.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else if .Values.mariadb.primary.persistence.storageClass }}
{{- .Values.mariadb.primary.persistence.storageClass }}
{{- end }}
{{- end }}

{{/*
Create environment variables for WordPress
*/}}
{{- define "my-blog.wordpress.env" -}}
- name: WORDPRESS_DB_HOST
  value: {{ include "my-blog.mariadb.fullname" . }}
- name: WORDPRESS_DB_PORT
  value: "3306"
- name: WORDPRESS_DB_NAME
  value: {{ .Values.mariadb.auth.database | quote }}
- name: WORDPRESS_DB_USER
  value: {{ .Values.mariadb.auth.username | quote }}
- name: WORDPRESS_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "my-blog.mariadb.secretName" . }}
      key: mariadb-password
- name: WORDPRESS_USERNAME
  value: {{ .Values.wordpress.auth.username | quote }}
- name: WORDPRESS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "my-blog.wordpress.secretName" . }}
      key: wordpress-password
- name: WORDPRESS_EMAIL
  value: {{ .Values.wordpress.auth.email | quote }}
- name: WORDPRESS_FIRST_NAME
  value: {{ .Values.wordpress.auth.firstName | quote }}
- name: WORDPRESS_LAST_NAME
  value: {{ .Values.wordpress.auth.lastName | quote }}
- name: WORDPRESS_BLOG_NAME
  value: {{ .Values.wordpress.auth.blogName | quote }}
{{- with .Values.extraEnvVars }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Create environment variables from ConfigMap
*/}}
{{- define "my-blog.wordpress.envFromConfigMap" -}}
{{- if .Values.extraEnvVarsCM }}
- configMapRef:
    name: {{ .Values.extraEnvVarsCM }}
{{- end }}
{{- end }}

{{/*
Create environment variables from Secret
*/}}
{{- define "my-blog.wordpress.envFromSecret" -}}
{{- if .Values.extraEnvVarsSecret }}
- secretRef:
    name: {{ .Values.extraEnvVarsSecret }}
{{- end }}
{{- end }}

{{/*
Validate WordPress authentication
*/}}
{{- define "my-blog.validateValues.wordpress.auth" -}}
{{- if and (empty .Values.wordpress.auth.password) (empty .Values.wordpress.auth.existingSecret) -}}
my-blog: wordpress.auth
    You must provide a password for WordPress admin user.
    Please set wordpress.auth.password or wordpress.auth.existingSecret
{{- end -}}
{{- end -}}

{{/*
Validate MariaDB authentication
*/}}
{{- define "my-blog.validateValues.mariadb.auth" -}}
{{- if and (empty .Values.mariadb.auth.password) (empty .Values.mariadb.auth.existingSecret) -}}
my-blog: mariadb.auth
    You must provide a password for MariaDB user.
    Please set mariadb.auth.password or mariadb.auth.existingSecret
{{- end -}}
{{- if and (empty .Values.mariadb.auth.rootPassword) (empty .Values.mariadb.auth.existingSecret) -}}
my-blog: mariadb.auth
    You must provide a root password for MariaDB.
    Please set mariadb.auth.rootPassword or mariadb.auth.existingSecret
{{- end -}}
{{- end -}}

{{/*
Return the WordPress persistence volume claim name
*/}}
{{- define "my-blog.wordpress.claimName" -}}
{{- if .Values.wordpress.persistence.existingClaim }}
{{- .Values.wordpress.persistence.existingClaim }}
{{- else }}
{{- printf "%s-wordpress" (include "my-blog.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the MariaDB persistence volume claim name
*/}}
{{- define "my-blog.mariadb.claimName" -}}
{{- if .Values.mariadb.primary.persistence.existingClaim }}
{{- .Values.mariadb.primary.persistence.existingClaim }}
{{- else }}
{{- printf "%s-mariadb" (include "my-blog.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create annotations with common annotations
*/}}
{{- define "my-blog.annotations" -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Create a standard probe configuration
*/}}
{{- define "my-blog.probe" -}}
{{- $probe := . -}}
{{- if $probe.enabled }}
initialDelaySeconds: {{ $probe.initialDelaySeconds }}
periodSeconds: {{ $probe.periodSeconds }}
timeoutSeconds: {{ $probe.timeoutSeconds }}
successThreshold: {{ $probe.successThreshold }}
failureThreshold: {{ $probe.failureThreshold }}
{{- end }}
{{- end }}
