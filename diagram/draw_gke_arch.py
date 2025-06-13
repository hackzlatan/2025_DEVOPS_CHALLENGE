from diagrams import Diagram, Cluster
from diagrams.onprem.network import Internet
from diagrams.gcp.network import LoadBalancing, Router, NAT, FirewallRules
from diagrams.k8s.network import Service as K8sService
from diagrams.k8s.compute import Deployment, Pod

with Diagram(
    "GKE Autopilot Architecture",
    show=False,
    direction="TB",
    filename="gke_architecture"
):
    # Internet ↔ External Network LB (L4)
    internet = Internet("Internet")
    lb       = LoadBalancing("Network LB\n(External IP)")
    internet >> lb

    # Kubernetes Service (LoadBalancer)
    svc = K8sService("Service: hello\n(type=LoadBalancer (L4))")
    lb >> svc

    # Agrupación VPC y Subnet con alias IPs
    with Cluster("VPC: la-vpc\n10.0.0.0/24"):
        with Cluster(            
            "Pods:10.1.0.0/24\n"
            "  Services:10.2.0.0/24"
        ):
            # Deployment → Autopilot Node Pool
            dp = Deployment("Autopilot\nNode Pool")
            svc >> dp

            # Pods reales
            pod1 = Pod("hello-App-pod-1")
            pod2 = Pod("hello-App-pod-2")
            dp >> [pod1, pod2]

        # Reglas de Firewall
        fw_cp  = FirewallRules("Allow control-plane\nTCP 10250\n35.191.0.0/16,130.211.0.0/22")
        fw_int = FirewallRules("Allow internal\n10.0.0.0/24")
        for pod in (pod1, pod2):
            fw_cp >> pod
            fw_int >> pod

    # Egress path via Cloud Router + NAT
    router = Router("Cloud Router")
    nat    = NAT("Cloud NAT")
    [pod1, pod2] >> router >> nat >> Internet("Internet Egress")
