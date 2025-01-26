terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
  #   credentials = "keys/creds.json"
  credentials = file(var.credentials)
  project     = var.project
  region      = "europe-west1"
}

resource "google_storage_bucket" "demo-expire" {
  name          = "tough-processor-312510-terra-bucket"
  location      = var.location
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

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}