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
	echo "Logging into GCP using interviewee credentials."
	gcloud auth activate-service-account --key-file=infra/.interviewee-creds.json


#Create Service Account
terraform-sa:
	gcloud iam service-accounts create terraform-sa --description="Cuenta de servicio para Terraform" --display-name="Terraform Service Account"
	gcloud projects add-iam-policy-binding $(shell cat .projectid.txt) --member="serviceAccount:terraform-sa@$(shell cat .projectid.txt).iam.gserviceaccount.com" --role="roles/owner"

#Create Service Account from file projectid.txt
terraform-sa-credentials:
	gcloud iam service-accounts keys create infra/.interviewee-creds.json --iam-account=terraform-sa@$(shell cat .projectid.txt).iam.gserviceaccount.com

