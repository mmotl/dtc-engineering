variable "credentials" {
    description = "The path to the service account key file"
    default = "keys/creds.json"
}

variable "project" {
    description = "The GCP project to deploy resources"
    default = "tough-processor-312510"
}

variable "location" {
    description = "The location/region for the GCS bucket and BigQuery dataset"
    default = "EU"
}
variable "bq_dataset_name"{
    description = "My BigQuery Dataet Name"
    default = "demo_dataset"
}

variable "gcs_bucket_name"{
    description = "My Storage Bucket Dataet Name"
    default = "demo_dataset"
}

variable "gcs_storage_class"{
    description = "Storage class for GCS bucket"
    default = "STANDARD"  
}