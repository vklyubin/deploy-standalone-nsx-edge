# vSphere Management

# export TF_VAR_vcenter_username=administrator@vsphere.local
# export TF_VAR_vcenter_password='VMware1!'
# export TF_VAR_vcenter_server=vcsa-01.example.com
# export TF_VAR_allow_unverified_ssl=true

vsphere_datacenter  = "datacenter-01"
vsphere_cluster     = "cluster-01"

nsx_edge_ova        = "/home/<user>/nsx-edge-3.2.4.1.0.24309050.ova"

vsphere_resource_pool = "nsx-edge-rp"
vsphere_vm_folder     = "nsx-edge-folder"
vsphere_mgmt_network  = "dvpg-mgmt-vm"
vsphere_data_network  = "dvpg-data-vm"
vsphere_disk_provisioning = "thin"
ntp_servers           = "10.10.247.51 10.97.0.60"
dns_servers           = "192.19.189.20 192.19.189.30"
domain_name           = "bus.example.com"

ip_subnet             = "10.209.155.128"
ip_netmask            = "255.255.255.192"
ip_gateway            = "10.209.155.129"
grub_password         = "VMware1!VMware1!"
root_password         = "VMware1!VMware1!"
admin_password        = "VMware1!VMware1!"


# valid deployments are: small, medium, large, xlarge
nsx_edges = {
  "edge1" = { form_factor = "small", mgmt_ip = "10.209.155.149", datastore = "cluster-01-vsanDS", esx_host = "sof6-hs1-b0215.bus.example.com"
          advanced_config = false, cpu_reservation_in_mhz = 43104, memory_reservation_percentage = 100, latency_sensitivity = "normal" },
  "edge2" = { form_factor = "small", mgmt_ip = "10.209.155.150", datastore = "cluster-01-vsanDS", esx_host = "sof6-hs1-b0216.bus.example.com"
          advanced_config = true, cpu_reservation_in_mhz = 4190, memory_reservation_percentage = 100, latency_sensitivity = "high" }
}
