# Deploy NSX Edge as OVA

## 1. Pre-reqs

1. System with access to internet or with locally available vmware/vsphere provider
2. NSX edge OVA file
3. Terraform scripts
4. Updated value files

## 2. Perform deployment

1. Initialize terraform

`terraform init`

2. Deploy NSX edges:

```bash
terraform plan

terraform apply
```

3. Register NSX Edge with NSX Manager

[Join NSX Edge with the Management Plane](https://techdocs.broadcom.com/us/en/vmware-cis/nsx/nsxt-dc/3-1/installation-guide/installing-nsx-edge/join-nsx-edges-with-the-management-plane.html)

## 3. Perform final configuration from NSX Manager GUI