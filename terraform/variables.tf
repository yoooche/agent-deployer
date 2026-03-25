variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "region" {
  description = "GCP Region"
  type = string
  default = "asia-east1"
}

variable "zone" {
  description = "GCP Zone"
  type = string
  default = "asia-east1-a"
}

variable "vm_name" {
  description = "VM Name"
  type = string
  default = "openclaw-vm"
}

variable "vm_machine_type" {
  description = "VM Machine Type"
  type = string
  default = "e2-small"
  
}

variable "artifact_name" {
  description = "Artifact Registry Repository Name"
  type = string
  default = "openclaw-artifact-registry"
}

variable "ssh_pub_key" {
  description = "SSH Public Key for VM access"
  type = string
}

variable "ssh_source_ranges" {
  description = "CIDRs allowed to SSH to the VM (tighten to your home IP for production)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}