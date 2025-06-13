# Configuración
PROJECT_ID ?= devops-462623
REGION     ?= us-central1

# Login en GCP
login:
	gcloud auth login
	gcloud config set project $(PROJECT_ID)
	gcloud config set compute/region $(REGION)

# Inicializar Terraform
init:
	cd terraform && terraform init

# Plan de cambios
plan:
	cd terraform && terraform plan \
		-var="project_id=$(PROJECT_ID)" \
		-var="region=$(REGION)"

# Aplicar infraestructura
apply:
	cd terraform && terraform apply \
		-var="project_id=$(PROJECT_ID)" \
		-var="region=$(REGION)" \
		-auto-approve

# Destruir infraestructura
destroy:
	cd terraform && terraform destroy \
		-var="project_id=$(PROJECT_ID)" \
		-var="region=$(REGION)" \
		-auto-approve

# Login Gcloud using credentials
login-gcloud:
	echo "Logging into GCP using interviewe credentials."
	gcloud auth activate-service-account --key-file=.interview-credentials.json

#Create Service Account
terraform-sa:
	gcloud iam service-accounts create terraform-sa --description="Service Account for Terraform" --display-name="Terraform Service Account"
	gcloud projects add-iam-policy-binding $(shell cat .projectid.txt) --member="serviceAccount:terraform-sa@$(shell cat .projectid.txt).iam.gserviceaccount.com" --role="roles/owner"

#Grant Permissions to the Service Account
sa-permissions:	
	gcloud projects add-iam-policy-binding $(shell cat .projectid.txt) --member="serviceAccount:terraform-sa@$(shell cat .projectid.txt).iam.gserviceaccount.com" --role="roles/owner"


#Create Credential File
credentials:
	gcloud iam service-accounts keys create .interview-credentials.json --iam-account=terraform-sa@$(shell cat .projectid.txt).iam.gserviceaccount.com

#
gke-connect:
	gcloud container clusters get-credentials la-gke --region us-central1 --project devops-462623

gke-deploy:
	kubectl apply -f kubernetes/hello-app.yaml && kubectl get deployments,services -n default

#Create Credential File
gke-info:	
	kubectl get deployments,services -n default

gke-delete:
	kubectl delete -f kubernetes/hello-app.yaml pipx run --spec diagrams python draw_gke_arch.py

diagram_drawing:
	pipx run --spec diagrams python draw_gke_arch.py