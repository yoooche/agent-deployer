output "vm_external_ip" {
  description = "Static external IP (reserved address bound to the VM)"
  value       = google_compute_address.vm_public.address
}

output "artifact_registry_url" {
  description = "Docker image URL prefix for docker push/pull"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_name}"
}

output "service_account_email" {
  description = "Service Account email for VM to access artifact registry"
  value       = google_service_account.vm_sa.email
}