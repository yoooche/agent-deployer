# Bootstrap: creates the GCS bucket for Terraform state.
# Run this ONCE locally before using the main Terraform config.
# Uses local backend - state stays on your machine; the bucket is the only resource.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # No backend - state is stored locally for this bootstrap run.
  # After the bucket exists, the main config will use it.
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tfstate" {
  # Include project_id for global uniqueness (GCS bucket names are shared across all GCP)
  name     = "${var.project_id}-tfstate"
  location = var.region
  # Prevent accidental deletion of state bucket
  force_destroy = false
}
