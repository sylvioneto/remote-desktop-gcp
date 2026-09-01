provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "remote_desktop" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags   = var.tags
  labels = var.labels

  boot_disk {
    auto_delete = true

    initialize_params {
      image  = var.boot_disk_image
      size   = var.boot_disk_size_gb
      type   = var.boot_disk_type
      labels = var.labels
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnetwork.id

    dynamic "access_config" {
      for_each = var.enable_external_ip ? [1] : []
      content {
        // Assigns an ephemeral public IP
      }
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup-script.sh.tftpl", {
    desktop_env     = var.desktop_environment
    rdp_username    = var.rdp_username
    rdp_password    = var.rdp_password
    install_chrome  = tostring(var.install_chrome_browser)
    custom_packages = join(" ", var.custom_packages)
  })

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = var.service_account_email != "" ? var.service_account_email : null
    scopes = var.service_account_scopes
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"],
    ]
  }
}
