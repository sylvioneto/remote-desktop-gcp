variable "project_id" {
  description = "The Google Cloud Project ID where the remote desktop instance will be deployed."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy the instance into."
  type        = string
  default     = "southamerica-east1"
}

variable "zone" {
  description = "The Google Cloud zone within the region."
  type        = string
  default     = "southamerica-east1-a"
}

variable "instance_name" {
  description = "The name of the GCE remote desktop virtual machine."
  type        = string
  default     = "remote-desktop-ubuntu"
}

variable "machine_type" {
  description = "The machine type for the remote desktop instance."
  type        = string
  default     = "n2-standard-8"
}

variable "boot_disk_type" {
  description = "The GCE persistent disk type for the boot disk (e.g. pd-ssd, pd-balanced, pd-standard)."
  type        = string
  default     = "pd-ssd"
}

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in gigabytes."
  type        = number
  default     = 200
}

variable "boot_disk_image" {
  description = "The OS image or image family to use for the boot disk (Ubuntu 24.04 LTS is default)."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "vpc_name" {
  description = "The name of the custom VPC network to create."
  type        = string
  default     = "remote-desktop-vpc"
}

variable "subnet_name" {
  description = "The name of the subnetwork to create within the VPC."
  type        = string
  default     = "remote-desktop-subnet"
}

variable "subnet_cidr" {
  description = "The IPv4 CIDR range for the custom subnetwork."
  type        = string
  default     = "10.10.0.0/24"
}

variable "allow_ssh_source_ranges" {
  description = "Source IP CIDR ranges allowed to connect to SSH (port 22). Default allows GCP IAP (35.235.240.0/20)."
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "allow_rdp_source_ranges" {
  description = "Source IP CIDR ranges allowed to connect to XRDP (port 3389). Default allows GCP IAP (35.235.240.0/20)."
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "rdp_username" {
  description = "Username for the local Linux user account permitted to log in via RDP."
  type        = string
  default     = "remoteuser"
}

variable "rdp_password" {
  description = "Password for the local Linux user account permitted to log in via RDP."
  type        = string
  default     = "remoteuser#359"
  sensitive   = true
}

variable "enable_external_ip" {
  description = "Whether to assign an external public IPv4 address to the instance. Default is false (uses Cloud NAT and IAP to comply with org policies)."
  type        = bool
  default     = false
}

variable "desktop_environment" {
  description = "The desktop environment to install and configure. Options: 'xfce', 'cinnamon', 'gnome', 'gnome-classic', 'kde'."
  type        = string
  default     = "xfce"
  validation {
    condition     = contains(["xfce", "cinnamon", "gnome", "gnome-classic", "kde"], var.desktop_environment)
    error_message = "Valid options for desktop_environment are: 'xfce', 'cinnamon', 'gnome', 'gnome-classic', 'kde'."
  }
}

variable "install_chrome_browser" {
  description = "Whether to download and install Google Chrome Stable browser on the instance."
  type        = bool
  default     = true
}

variable "custom_packages" {
  description = "List of extra packages to install during startup script execution."
  type        = list(string)
  default     = ["less", "bzip2", "zip", "unzip", "tasksel", "wget", "curl", "git", "htop", "dbus-x11", "pulseaudio"]
}

variable "service_account_email" {
  description = "Custom service account email to associate with the VM. If omitted, the default Compute Engine service account is used."
  type        = string
  default     = ""
}

variable "service_account_scopes" {
  description = "List of OAuth scopes to assign to the instance service account."
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "tags" {
  description = "Network tags to apply to the instance."
  type        = list(string)
  default     = ["remote-desktop", "http-server", "https-server"]
}

variable "labels" {
  description = "Key-value labels to attach to the VM instance and its persistent disk."
  type        = map(string)
  default = {
    workload   = "remote-desktop"
    managed-by = "terraform"
  }
}
