variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Invalid project ID!"
  }
}

variable "jenkins_account_id" {
  type        = string
  description = "The account id of the service account for Jenkins job build"
  default     = "jenkis"
}

variable "jenkins_build_url" {
  type        = string
  description = "The Jenkins job build URL"
  default     = "http://jenkins.localhost:2529/job/gcp-test-bucket/"
}

variable "gcs_region" {
  type        = string
  description = "Google Cloud region for GCS test bucket"
  default     = "europe-west3"
}
