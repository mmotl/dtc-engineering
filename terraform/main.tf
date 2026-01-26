terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "tough-processor-312510-bucket"
  location      = var.bucket_location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# resource "google_bigquery_dataset" "dataset" {
#   dataset_id = "<The Dataset Name You Want to Use>"
#   project    = "<Your Project ID>"
#   location   = "US"
# }