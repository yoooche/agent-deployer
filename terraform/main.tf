terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "~> 5.0"
    }
  }

  backend "gcs" {
    # Bucket name passed at init: -backend-config="bucket=${project_id}-tfstate"
    # Must match the bucket created by bootstrap
    prefix = "terraform/state"
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
      size = 20
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

  metadata = {
    ssh-keys = "louis-agent:${var.ssh_pub_key}"
  }

  # Install Docker and start it when the VM is created
  metadata_startup_script = <<-EOT
    apt-get update -y
    apt-get install -y docker.io docker-compose-plugin curl gnupg
    systemctl start docker
    systemctl enable docker
    usermod -aG docker louis-agent || true
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
      https://packages.cloud.google.com/apt cloud-sdk main" \
      | tee /etc/apt/sources.list.d/google-cloud-sdk.list
    apt-get update -y && apt-get install -y google-cloud-sdk
  EOT

  allow_stopping_for_update = true
}