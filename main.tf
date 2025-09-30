# Create Workload Identity Pool Provider for Jenkins
resource "random_integer" "jenkins-wif" {
  min = 100
  max = 999
}

module "jenkins-wif" {
  source            = "Cyclenerd/wif-jenkins/google"
  version           = "~> 1.0.0"
  project_id        = var.project_id
  pool_id           = "jenkins-${random_integer.jenkins-wif.result}"
  provider_id       = "jenkins-oidc-${random_integer.jenkins-wif.result}"
  issuer_uri        = "https://jenkins.localhost"
  allowed_audiences = ["https://jenkins.localhost"]
  # Export of public OIDC JSON Web Key (JWK) file
  jwks_json_file = "jenkins-jwk.json"
}

# Create new service account for Jenkins build
resource "google_service_account" "jenkins" {
  project      = var.project_id
  account_id   = var.jenkins_account_id
  display_name = "Jenkins (WIF)"
  description  = "Service Account for Jenkins build (Terraform managed)"
}

# Allow service account to login via WIF and only from specific Jenkins build with URL in subject
module "jenkins-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = ">= 1.1.0"
  project_id = var.project_id
  pool_name  = module.jenkins-wif.pool_name
  account_id = google_service_account.jenkins.account_id
  subject    = var.jenkins_build_url
  depends_on = [google_service_account.jenkins]
}

# Create a Google Cloud Storage bucket to test access
resource "random_uuid" "gcs-test-bucket" {
}

module "gcs-test-bucket" {
  source     = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version    = "~> 11.1"
  project_id = var.project_id
  name       = "jenkins-gcs-${random_uuid.gcs-test-bucket.result}"
  location   = var.gcs_region
  iam_members = [{
    role   = "roles/storage.objectAdmin"
    member = "serviceAccount:${google_service_account.jenkins.email}"
  }]
  depends_on = [google_service_account.jenkins]
}
