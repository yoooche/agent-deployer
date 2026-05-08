variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the bucket (must match main Terraform)"
  type        = string
  default     = "asia-east1"
}
