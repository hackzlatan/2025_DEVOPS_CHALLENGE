# 2025_DEVOPS_CHALLENGE  
**Networking infrastructure deployed via Terraform**  
Hosts a containerized, stateless app on GCP using a private, VPC-native GKE Autopilot cluster.

---

## Architecture Overview

1. **Custom VPC** (`google_compute_network`)  
   - **What**: Creates a VPC in “custom” mode (no auto-subnets).  
   - **Why**: Gives you full control over IP ranges and zone placement, avoids unwanted subnets, and enforces clear network isolation.

2. **Private Subnet with Secondary IP Ranges** (`google_compute_subnetwork`)  
   - **Primary CIDR**: e.g. `10.0.0.0/24` for node IPs.  
   - **`private_ip_google_access = true`**: allows private nodes (no public IP) to reach Google APIs privately.  
   - **Secondary Ranges**:  
     - **Pods**: `10.1.0.0/24`  
     - **Services**: `10.2.0.0/24`  
   - **Why**: Alias IPs are required for VPC-native GKE so each Pod and Service gets its own VPC IP.

3. **Service Peering for Private Control Plane**  
   - Resources: `google_compute_global_address` + `google_service_networking_connection`  
   - Reserves a `/28` block (e.g. `10.0.3.0/28`) for the GKE master’s private endpoint.  
   - Creates a peering to `servicenetworking.googleapis.com`, fully isolating the control plane inside your VPC.

4. **Cloud Router & Cloud NAT** (`google_compute_router` + `google_compute_router_nat`)  
   - **Cloud Router**: manages dynamic routes.  
   - **Cloud NAT**: gives private nodes internet egress (for pulling images, patches, etc.) via a single static IP (`google_compute_address`).  
   - **Why**: Without NAT, private nodes cannot reach external registries or APIs.

5. **Firewall Rules** (`google_compute_firewall`)  
   - **Control-plane → nodes**: allow TCP/10250 from GKE health-check ranges (`35.191.0.0/16`, `130.211.0.0/22`).  
   - **Internal traffic**: allow all traffic within the subnet.  
   - **Why**: needed for master health-checks and pod-to-pod communication.

6. **Private Cluster Configuration** (`private_cluster_config`)  
   - `enable_private_nodes = true`  
   - `enable_private_endpoint = false`  
   - `master_ipv4_cidr_block = var.master_ipv4_cidr_block`  
   - **Why**: Ensures neither the control plane nor the nodes have public IPs.

7. **IP Allocation Policy in Cluster** (`ip_allocation_policy`)  
   - References the “pods” and “services” secondary ranges.  
   - GKE automatically uses alias IPs within those ranges for Pods & Services.

---

## How to Deploy

**1 Enable Required GCP APIs**  
   ```bash
   gcloud services enable \
     container.googleapis.com \
     compute.googleapis.com \
     servicenetworking.googleapis.com \
     iamcredentials.googleapis.com


**2 Add your project id to the file .projectid.txt**  
   gcloud config get-value project > projectid.txt

**3 Create the SA and add the permissions, and generate the credentials file**  
   make login
   make terraform-sa	
   make credentials
   make login-gcloud

**4 Create the infrastructure using terraform**  
   make init
   make plan
   make apply

**5 Install the application in GKE**  
   make gke-connect
   make gke-deploy

**6 Access to your App deployed using the external ip provided**  
   make gke-info

**7 To draw the diagram**  
   make diagram_drawing

**8 Destory Infrastructure **  
  make gke-delete
  make destroy

