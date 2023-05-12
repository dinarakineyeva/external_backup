terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.13"
}

provider "google-beta" {
  project     = var.project_id
  credentials = file("cred.json")
}

provider "google" {
  project     = var.gcp_project_id
  credentials = file("cred.json")
}
