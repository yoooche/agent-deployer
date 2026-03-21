output "vm_external_ip" {
  description = "External IP of the GCE VM"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "artifact_registry_url" {
  description = "Docker image URL prefix for docker push/pull"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_name}"
}

output "service_account_email" {
  description = "Service Account email for VM to access artifact registry"
  value       = google_service_account.vm_sa.email
}