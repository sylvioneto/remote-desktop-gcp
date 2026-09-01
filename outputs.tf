output "vpc_network_name" {
  description = "The name of the created VPC network."
  value       = google_compute_network.vpc_network.name
}

output "vpc_network_id" {
  description = "The ID of the created VPC network."
  value       = google_compute_network.vpc_network.id
}

output "subnetwork_name" {
  description = "The name of the created subnetwork."
  value       = google_compute_subnetwork.vpc_subnetwork.name
}

output "subnetwork_id" {
  description = "The ID of the created subnetwork."
  value       = google_compute_subnetwork.vpc_subnetwork.id
}

output "subnetwork_cidr" {
  description = "The CIDR range of the created subnetwork."
  value       = google_compute_subnetwork.vpc_subnetwork.ip_cidr_range
}

output "instance_id" {
  description = "The server-assigned unique identifier for the VM instance."
  value       = google_compute_instance.remote_desktop.instance_id
}

output "instance_name" {
  description = "The name of the remote desktop VM instance."
  value       = google_compute_instance.remote_desktop.name
}

output "instance_zone" {
  description = "The GCP zone where the VM instance is running."
  value       = google_compute_instance.remote_desktop.zone
}

output "instance_internal_ip" {
  description = "The primary internal IPv4 address of the instance."
  value       = google_compute_instance.remote_desktop.network_interface[0].network_ip
}

output "instance_external_ip" {
  description = "The external IPv4 address assigned to the instance (if enabled)."
  value       = length(google_compute_instance.remote_desktop.network_interface[0].access_config) > 0 ? google_compute_instance.remote_desktop.network_interface[0].access_config[0].nat_ip : "None"
}

output "rdp_username" {
  description = "Username for RDP remote desktop authentication."
  value       = var.rdp_username
}

output "ssh_command" {
  description = "Command to SSH into the instance using gcloud CLI with IAP tunneling."
  value       = "gcloud compute ssh ${google_compute_instance.remote_desktop.name} --project=${var.project_id} --zone=${google_compute_instance.remote_desktop.zone} --tunnel-through-iap"
}

output "rdp_iap_tunnel_command" {
  description = "Command to create an encrypted IAP TCP tunnel from your local machine to the VM's XRDP port (3389)."
  value       = "gcloud compute start-iap-tunnel ${google_compute_instance.remote_desktop.name} 3389 --local-host-port=localhost:3389 --zone=${google_compute_instance.remote_desktop.zone} --project=${var.project_id}"
}

output "remote_desktop_connection_instructions" {
  description = "Instructions to connect to the VM from any Remote Desktop client (Windows, macOS, Linux)."
  value       = <<-EOT
    ========================================================================================
    HOW TO CONNECT VIA ANY REMOTE DESKTOP CLIENT (XRDP / XFCE):
    ========================================================================================
    1. Wait ~2-3 minutes after 'terraform apply' for the startup script to finish
       upgrading packages, installing Xfce desktop, and starting XRDP.

    2. Start the secure Google Cloud IAP Tunnel on your local machine:
       -------------------------------------------------------------------------------------
       gcloud compute start-iap-tunnel ${google_compute_instance.remote_desktop.name} 3389 \
           --local-host-port=localhost:3389 \
           --zone=${google_compute_instance.remote_desktop.zone} \
           --project=${var.project_id}
       -------------------------------------------------------------------------------------
       (Leave this terminal running in the background while you are connected).

    3. Open your favorite Remote Desktop application:
       - Windows: Open 'Remote Desktop Connection' (mstsc.exe)
       - macOS: Open 'Microsoft Remote Desktop' or 'Jump Desktop'
       - Linux: Open 'Remmina' (choose RDP)

    4. Connect to PC / Server:
       Computer: localhost:3389

    5. Enter your credentials when prompted:
       Username: ${var.rdp_username}
       Password: (configured via rdp_password variable, default: remoteuser#359)
    ========================================================================================
  EOT
}
