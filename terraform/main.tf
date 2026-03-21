terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  location = var.region
  repository_id = var.artifact_name
  format = "DOCKER"
}

# Service Account
resource "google_service_account" "vm_sa" {
  account_id = "vm-deployer-sa"
  display_name = "VM Deployer Service Account"
}

# The permission for service account to access artifact registry
resource "google_project_iam_member" "ar_reader" {
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_compute_instance" "vm" {
  name = var.vm_name
  machine_type = var.vm_machine_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {} # This is for the public IP address
  }

  service_account {
    email = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  # Install Docker and start it when the VM is created
  metadata_startup_script = <<-EOF
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
  EOF

  allow_stopping_for_update = true
}