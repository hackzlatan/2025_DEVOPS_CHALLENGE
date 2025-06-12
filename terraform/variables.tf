variable "project_id" {
  type        = string
  description = "ID del proyecto GCP"
}

variable "region" {
  type        = string
  description = "Región GCP (para Autopilot Regional)"
  default     = "us-central1"
}

variable "credentials_file" {
  type        = string
  description = "Ruta al JSON de la service account"
  default     = "infra/.interviewee-creds.json"
}
