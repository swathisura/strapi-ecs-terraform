# Strapi on AWS ECS (EC2) with Terraform & GitHub Actions

## Overview
This project deploys **Strapi CMS** on **AWS ECS (EC2 launch type)**, fully managed with **Terraform**.  
CI/CD is implemented using **GitHub Actions**, which builds the Docker image, pushes it to **AWS ECR**, and updates the ECS service automatically.

---

## Steps Followed

### 1. Repository Setup
- Created a new GitHub repository.  
- Added a `.gitignore` to exclude `node_modules`, `.env`, and `terraform.tfstate`.

### 2. Strapi Application
- Initialized a Strapi project using:

npx create-strapi-app@latest strapi-app --typescript --no-run
Created a Dockerfile.

dockerfile
Copy code
FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 1337
CMD ["npm", "run", "start"]
This Dockerfile sets up the environment, installs dependencies, builds the app, and runs it.

3. Terraform Infrastructure
Configured AWS provider.

Created VPC, subnets, and security groups.

Set up an ECS cluster with EC2 launch type.

Defined ECS task definition and service.

Created necessary IAM roles for ECS tasks and EC2 instances.

4. Docker Registry (ECR)
Created an AWS ECR repository for the Strapi Docker image.

The GitHub Actions workflow builds the Docker image and pushes it to this ECR repository.

5. CI/CD with GitHub Actions
Workflow file: .github/workflows/deploy.yml

On push to main branch:

Checkout the repository

Configure AWS credentials

Build Docker image

Push image to AWS ECR

Apply Terraform to update ECS task definition with the new image

6. Deployment
Once the workflow completes, the ECS service automatically runs the latest Strapi Docker image.

Application is accessible through the configured ECS service endpoint.

Key Commands
bash
Copy code
# Terraform commands
terraform init
terraform plan
terraform apply -auto-approve

# Docker commands (for local testing)
docker build -t strapi-app:latest .
docker push <ECR_REPO_URL>:latest
Notes
Using EC2 launch type instead of Fargate.

Image versioning can be used instead of latest for better control.

CI/CD automation ensures zero manual deployment steps.

Fully automated: pushing code to main triggers the entire build and deploy process.
