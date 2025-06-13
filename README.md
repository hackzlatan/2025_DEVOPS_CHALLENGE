# 2025_DEVOPS_CHALLENGE
Infrastructure deployed with Terraform to host a containerized stateless app on GCP

1. VPC Custom (google_compute_network)
Qué hace: Crea una VPC en “modo custom”, es decir, sin subredes automáticas.

Por qué: Te da control completo sobre qué rangos de IP usas y en qué zonas, evitando asignaciones no deseadas y facilitando el aislamiento de redes.

2. Subred Privada con Secondary IP Ranges (google_compute_subnetwork)
ip_cidr_range: el bloque principal donde viven las IP de los nodos (p.ej. 10.0.0.0/22).

private_ip_google_access = true: permite que los nodos sin IP pública alcancen APIs de Google (p.ej. Container Registry, Secret Manager) a través de su IP interna.

secondary_ip_range (pods y services): habilita Alias IPs, de modo que cada Pod y cada servicio recibe su propia IP dentro de la VPC.

Rango “pods”: p.ej. 10.0.1.0/24

Rango “services”: p.ej. 10.0.2.0/24

Alias IPs son obligatorios para clústeres VPC-native y permiten un enrutamiento más fino y aislamiento de CNI.

3. Peering de Servicio para Control Plane Privado
google_compute_global_address + google_service_networking_connection

Reservamos un bloque /28 (p.ej. 10.0.3.0/28) para el endpoint privado del plano de control de GKE.

Mediante Service Networking hacemos peering entre tu VPC y el servicio servicenetworking.googleapis.com, lo que habilita el endpoint privado sin exponerlo a Internet.

Esto aísla completamente tu control plane dentro de la red VPC.

4. Cloud Router y Cloud NAT (google_compute_router + google_compute_router_nat)
Cloud Router: componente que gestiona rutas dinámicas para NAT.

Cloud NAT: permite que los nodos sin IP pública puedan “salir” a Internet (para descargar imágenes, parches, etc.) usando una IP estática.

Asignamos una IP estática regional (google_compute_address), y configuramos NAT para que todo el tráfico egress de la subred pase por ella.

Sin NAT, los nodos privados no tendrían salida a repositorios públicos ni a APIs externas.

5. Reglas de Firewall (google_compute_firewall)
Control plane → nodos

Permite TCP/10250 desde los rangos de salud de GKE (35.191.0.0/16, 130.211.0.0/22).

Necesario para que el plano de control (master) pueda orquestar y «hacer health check» de tus nodos.

Tráfico interno

Permite “all” dentro del rango de la subred.

Asegura que pods, servicios y nodos puedan comunicarse libremente entre sí (p.ej. Service mesh, consultas internas).

6. Configuración de Clúster Privado (private_cluster_config)
enable_private_nodes = true: los nodos no reciben IP pública.

enable_private_endpoint = false: el endpoint del control plane solo es accesible vía la subred privada (no publica).

master_ipv4_cidr_block: el bloque /28 que definimos para el peering.

Garantiza que ni el plano de control ni los nodos sean directamente accesibles desde Internet.

7. IP Allocation Policy en el Clúster (ip_allocation_policy)
Solo referenciamos los nombres de los rangos “pods” y “services” que creamos en la subred.

GKE asigna automáticamente Alias IPs dentro de esos rangos a Pods y Servicios.

8. Add-ons y Network Policy
http_load_balancing (addon): habilita el controlador de Ingress/Service tipo LoadBalancer para exponer servicios vía un LB interno (puedes anotarlo luego como kubernetes.io/ingress.class: “gce-internal”).

network_policy: con Calico activado, puedes aplicar reglas de aislamiento a nivel de Pod (p. ej. solo permitir HTTP en ciertos namespaces).

Flujo general de red al desplegar un Service tipo LoadBalancer interno:
Tu Deployment/Service en Kubernetes

GKE pide al LB interno en tu VPC un Frontend IP dentro de la subred

El tráfico entra al LB (solo accesible dentro de la VPC o mediante VPN/Peering)

El LB enruta a los Pods usando sus Alias IPs en el rango “pods”

Con esta topología, cumples:

Seguridad: ni plano de control ni nodos expuestos públicamente.

Escalabilidad: Autopilot gestiona los nodos según demanda.

Aislamiento: políticas de red y LB internos garantizan límites claros.

Conectividad: Cloud NAT + Private Google Access cubren todas las necesidades de egress.


