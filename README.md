# Infrastructure CI/CD project

This repository contains the infrastructure and microservices setup for a cloud-based application deployed on AWS, managed using Infrastructure as Code (IaC) with Terraform, and integrated with CI/CD pipelines through GitHub Actions and ArgoCD.

## Project Structure

- **`terraform/`**: Contains Terraform code to provision the cloud infrastructure on AWS, including:
  - **Amazon EKS**: Kubernetes cluster where the microservices are deployed.
  - **IAM Roles and Policies**: To ensure proper permissions for the microservices and other AWS resources.
  - **S3 Bucket**: Used by Microservice 2 to store data processed from SQS.
  - **SQS Queue**: The message queue that connects the two microservices.
  - **STS (Secure Token Service)**: Handles secure role-based authentication for the services.
  - **ArgoCD**: Used for continuous deployment of the microservices, deployed via Helm.

- **`microservices/`**: Includes the application's source code and Dockerfiles for both microservices in this project
  - **Microservice 1**:
    - Listens to requests from an ELB.
    - Validates the token stored in AWS Secret Manager.
    - Ensures that the request payload contains valid data (with 4 text fields).
    - Publishes validated data to an SQS queue.
  - **Microservice 2**:
    - Polls the SQS queue at regular intervals (60s).
    - Retrieves messages from the queue and uploads them to an S3 bucket.
    - Clears the SQS queue to prevent duplications on the S3 bucket.

 
- **`kubernetes/`**: Contains the kubernetes manifests for deploying the microservices on the cluster
  - **Microservice 1**: Contains the deployment, service account, and service configuration (with type LoadBalancer) for exposing the microservice to external traffic.
  - **Microservice 2**: Contains the deployment configuration, which utilizes the service account created in Microservice 1 for access control.

## CI/CD Pipeline

### CI (Continuous Integration)
- GitHub Actions is used to build and tag Docker images for both microservices and pushes them to DockerHub.
- A new tag is created for each deployment, which is then automatically updated in the repository.

### CD (Continuous Deployment)
- ArgoCD monitors the repository for changes (in our case, the changes are the image versions updated by the CI jobs) and auto-syncs the applications based on the new image tag

## How to Deploy

### Prerequisites
- aws-cli
- kubectl
- terraform
- argocd-cli

1. **Clone the repository**
   ```bash
   git clone https://github.com/LiorAtari/aws-project.git
   cd aws-project
   
2. **AWS Setup**
   - Please follow the instructions from the email for the AWS account setup before moving to the next step.

3. **Infrastructure Setup**:
   Navigate to the `terraform/` directory and run the following commands to deploy the infrastructure:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply

4. **Run the script**  
   Once terraform finishes provisioning everything, run the following commands:
   ```bash
   chmod +x run.sh
   ./run.sh
  
