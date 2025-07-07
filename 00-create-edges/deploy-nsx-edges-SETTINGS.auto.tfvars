# export TF_VAR_vcenter_username=administrator@vsphere.local
# export TF_VAR_vcenter_password='VMware1!'
# export TF_VAR_vcenter_server=tps-vcsa-01.bus.broadcom.net
# export TF_VAR_allow_unverified_ssl=true

vsphere_datacenter        = "tps-datacenter-01"
vsphere_cluster           = "tps-cluster-01"

nsx_edge_ova              = "/home/vklyubin/nsx-edge-3.2.4.1.0.24309050.ova"

vsphere_resource_pool     = "vklyubin"
vsphere_vm_folder         = "vklyubin"
vsphere_mgmt_network      = "tps-dvpg-mgmt-vm"
vsphere_data_network      = "TPS-SEG-S-OVLY-vklyubin-trunk"
vsphere_disk_provisioning = "thin"
ntp_servers               = "10.10.247.51 10.97.0.60"
dns_servers               = "192.19.189.20 192.19.189.30"
domain_name               = "bus.broadcom.net"

ip_subnet                 = "10.209.155.128"
ip_netmask                = "255.255.255.192"
ip_gateway                = "10.209.155.129"
grub_password             = "VMware1!VMware1!"
root_password             = "VMware1!VMware1!"
admin_password            = "VMware1!VMware1!"

nsx_manager_ip            = "tps-nsx-01.bus.broadcom.net"
nsx_manager_username      = "admin"
nsx_manager_password      = "VMware1!VMware1!"
nsx_manager_thumbprint    = "4f87b93c082d6daa9591dbab141b495635cd68b01de115cdfe5c1ddf4cbcc015"

# valid deployments are: small, medium, large, xlarge
nsx_edges = {
  "edge3" = { form_factor = "medium", mgmt_ip = "10.209.155.153", datastore = "tps-cluster-01-vsanDS", esx_host = "sof6-hs1-b0216.bus.broadcom.net"
          advanced_config = false, cpu_reservation_in_mhz = 4190, memory_reservation_percentage = 100, latency_sensitivity = "high" }
}