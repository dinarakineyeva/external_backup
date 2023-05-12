# Create a BASTION HOST for Atlas Cluster to take backup
resource "google_compute_instance" "mongo_instance" {
  name         = "mongo-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
 allow_stopping_for_update = true
 desired_status = "RUNNING"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    subnetwork = "default"

    access_config {
      nat_ip = google_compute_address.mongo_address.address
    }
  }

metadata = {
    "cred" = "${file("cred.json")}"
  }
  
 metadata_startup_script = file("${path.module}/script.sh")
} 

resource "google_compute_address" "mongo_address" {
  name   = "mongo-address"
  region = var.gcp_region
}

# Create a firewall rule to allow inbound traffic on port 27017 for MongoDB
resource "google_compute_firewall" "mongo_firewall" {
  name    = "mongo-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = ["0.0.0.0/0"]
}

output "mongo_instance_ip" {
  value = google_compute_instance.mongo_instance.network_interface[0].access_config[0].nat_ip
}
