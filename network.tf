resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "Custom VPC Network for Chrome Remote Desktop VM"
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
  description              = "Subnetwork in ${var.region} for Remote Desktop instances"
}

# Cloud Router for outbound NAT (enables private VMs to access the internet)
resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule allowing SSH (port 22) from IAP and configured ranges
resource "google_compute_firewall" "allow_ssh" {
  name        = "${var.vpc_name}-allow-ssh"
  network     = google_compute_network.vpc_network.name
  description = "Allow inbound SSH access to remote desktop VM (including IAP tunnel)"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allow_ssh_source_ranges
  target_tags   = var.tags
}

# Firewall rule allowing XRDP (port 3389) from IAP and configured ranges
resource "google_compute_firewall" "allow_rdp" {
  name        = "${var.vpc_name}-allow-rdp"
  network     = google_compute_network.vpc_network.name
  description = "Allow inbound RDP access (port 3389) via IAP tunnel or allowed ranges"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.allow_rdp_source_ranges
  target_tags   = var.tags
}

# Firewall rule allowing internal traffic within the subnetwork
resource "google_compute_firewall" "allow_internal" {
  name        = "${var.vpc_name}-allow-internal"
  network     = google_compute_network.vpc_network.name
  description = "Allow internal traffic within the VPC subnetwork"

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr]
}
