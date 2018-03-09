// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.credentials}")}"
 project     = "${var.gcp_project}" 
 region      = "${var.region}"
}

// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.name}-vpc-${var.suffix}"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet" {
 name          = "${var.name}-subnet-${var.suffix}"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${var.name}-vpc-${var.suffix}"
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.region}"
}
// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall-${var.suffix}"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

//  source_ranges = ["0.0.0.0/0"]
}

data "google_compute_zones" "available" {}

resource "google_compute_instance" "ece" {
 //project = "${google_project_services.project.project}"
 zone = "${data.google_compute_zones.available.names[0]}"
 name = "tf-compute-1"
 machine_type = "f1-micro"
 boot_disk {
   initialize_params {
     image = "ubuntu-1604-xenial-v20170328"
   }
 }
 network_interface {
   subnetwork = "${google_compute_subnetwork.subnet.name}"
   access_config {
   }
 }
}

output "instance_id" {
 value = "${google_compute_instance.ece.self_link}"
}
