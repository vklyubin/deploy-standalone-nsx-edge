########################################################################################################################
# Copyright 2025 VMwareby Broadcom, Inc.  All rights reserved.
# Provided as-is, NO VMware official support.
#
# Maintainer:     Vladimir Klyubin
# Org:            VMware EMEA - Telco PSO
# e-mail:         vladimir.klyubn@broadcom.com
########################################################################################################################
# Provider
terraform {
  required_providers {
    vsphere = {
      source = "vmware/vsphere"
    }
  }
}

provider "vsphere" {
  user           = var.vcenter_username
  password       = var.vcenter_password
  vsphere_server = var.vcenter_server
  # Proceed even with self-signed cert
  allow_unverified_ssl = var.allow_unverified_ssl
}

################################################################
# Credentials
variable "vcenter_username" {}
variable "vcenter_server" {}
variable "vcenter_password" {  
    type = string
    sensitive = true 
}
variable "allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = false
}

variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
variable "vsphere_mgmt_network" {}
variable "vsphere_data_network" {}
variable "vsphere_disk_provisioning" {
  type = string
  default = "thin"
}
variable "vsphere_resource_pool" {  
    default = ""
    type = string 
}

variable "nsx_edge_ova" {}
variable "domain_name" {}
variable "ntp_servers" {
  type = string
  default = ""
}
variable "dns_servers" {
  type = string
  default = ""
}

variable "nsx_edges" {
  type = map
  default = {}
}

variable "vsphere_vm_folder" {
  description = "vSphere folder for the VMs"
  type        = string
  default     = ""
}

# Edges Configurations
variable "ip_subnet" {}
variable "ip_netmask" {}
variable "ip_gateway" {}
variable "isSSHEnabled" {
  # Case sensitive
  default = "True" 
}
variable "allowSSHRootLogin" {
  # Case sensitive
  default = "False"
}

variable "grub_password" {
  type = string
  sensitive = true
  default = "VMware1!VMware1!"
}
variable "root_password" {
  type = string
  sensitive = true
  default = "VMware1!VMware1!"
}
variable "admin_password" {
  type = string
  sensitive = true
  default = "VMware1!VMware1!"
}

# vSphere inputs
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}
data "vsphere_compute_cluster" "vsphere_cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_host" "esx_host" {
  for_each      = var.nsx_edges
  name          = each.value.esx_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool == "" ? "${data.vsphere_compute_cluster.vsphere_cluster.name}/Resources" : var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = var.vsphere_vm_folder == "" ? "/${data.vsphere_datacenter.datacenter.name}/vm" : "/${data.vsphere_datacenter.datacenter.name}/vm/${var.vsphere_vm_folder}"
}

data "vsphere_datastore" "datastore" {
  for_each          = var.nsx_edges
  name              = each.value.datastore
  datacenter_id     = data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "mgmt_network" {
  name              = var.vsphere_mgmt_network
  datacenter_id     = data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "data_network" {
  name              = var.vsphere_data_network
  datacenter_id     = data.vsphere_datacenter.datacenter.id
}

################################################################
# NSX-T Edge

data "vsphere_ovf_vm_template" "ovfLocal" {
  for_each              = var.nsx_edges
  name                  = each.key
  disk_provisioning     = var.vsphere_disk_provisioning
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  datastore_id          = data.vsphere_datastore.datastore[each.key].id
  host_system_id        = data.vsphere_host.esx_host[each.key].id
  local_ovf_path        = var.nsx_edge_ova
  deployment_option     = each.value.form_factor
  ovf_network_map = {
      "Network 0" : data.vsphere_network.mgmt_network.id
      "Network 1" : data.vsphere_network.data_network.id
      "Network 2" : data.vsphere_network.data_network.id
      "Network 3" : data.vsphere_network.data_network.id
      "Network 4" : data.vsphere_network.data_network.id
  }
}

resource "vsphere_virtual_machine" "nsx_edge" {
  for_each                    = var.nsx_edges
  name                        = each.key
  resource_pool_id            = data.vsphere_resource_pool.pool.id
  datastore_id                = data.vsphere_datastore.datastore[each.key].id
  host_system_id              = data.vsphere_host.esx_host[each.key].id
  wait_for_guest_net_timeout  = 0
  wait_for_guest_ip_timeout   = 0
  datacenter_id               = data.vsphere_datacenter.datacenter.id
  num_cpus                    = data.vsphere_ovf_vm_template.ovfLocal[each.key].num_cpus
  num_cores_per_socket        = data.vsphere_ovf_vm_template.ovfLocal[each.key].num_cores_per_socket
  cpu_reservation             = each.value.advanced_config == true ? each.value.cpu_reservation_in_mhz : null
  latency_sensitivity         = each.value.advanced_config == true ? each.value.latency_sensitivity : null
  memory                      = data.vsphere_ovf_vm_template.ovfLocal[each.key].memory
  memory_reservation          = each.value.advanced_config == true ? data.vsphere_ovf_vm_template.ovfLocal[each.key].memory * each.value.memory_reservation_percentage / 100 : 0
  guest_id                    = data.vsphere_ovf_vm_template.ovfLocal[each.key].guest_id
  scsi_type                   = data.vsphere_ovf_vm_template.ovfLocal[each.key].scsi_type
  folder                      = data.vsphere_folder.folder.path
  # alternate_guest_name        = var.hostname
  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfLocal[each.key].ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
  ovf_deploy {
      allow_unverified_ssl_cert = true
      local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal[each.key].local_ovf_path
      disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal[each.key].disk_provisioning
      ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal[each.key].ovf_network_map
  }
  vapp {
      properties = {
        "nsx_grub_passwd"       = var.grub_password
        "nsx_passwd_0"          = var.admin_password
        "nsx_cli_passwd_0"      = var.root_password
        "nsx_hostname"          = "${each.key}.${var.domain_name}"
        "nsx_ip_0"              = each.value.mgmt_ip
        "nsx_netmask_0"         = var.ip_netmask
        "nsx_gateway_0"         = var.ip_gateway
        "nsx_dns1_0"            = var.dns_servers
        "nsx_domain_0"          = var.domain_name
        "nsx_ntp_0"             = var.ntp_servers
        "nsx_isSSHEnabled"      = var.isSSHEnabled
        "nsx_allowSSHRootLogin" = var.allowSSHRootLogin
        # "nsx_allowSSHRootLogin" = var.allowSSHRootLogin
      }
  }
  lifecycle {
    ignore_changes = all
  }
}
