output "jenkins-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.jenkins-wif.provider_name
}

output "jenkins-account-email" {
  description = "The service account id for the Jenkins build"
  value       = google_service_account.jenkins.email
}

output "gcs-test-bucket" {
  description = "The Google Cloud Storage test bucket"
  value       = module.gcs-test-bucket.name
}
