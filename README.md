# Plantasia 🌿

A simple plant watering tracker application built with Go, MongoDB, and Kubernetes, for plants and people who love them.

## Architecture

- Frontend: Static HTML/JavaScript
- Backend: Go HTTP server
- Database: MongoDB
- Infrastructure: AWS EKS (Kubernetes) and EC2 (MongoDB)

## Prerequisites

- AWS CLI configured
- Docker installed
- kubectl configured for your EKS cluster
- Go 1.21 or later

## Local Development

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd plantasia
   ```

2. Install dependencies:
   ```bash
   go mod download
   ```

3. Run locally:
   ```bash
   go run main.go
   ```

## Deployment

1. Build and push Docker image:
   ```bash
   # Replace [AWS_ACCOUNT_ID] and [REGION] with your values
   docker buildx build --platform linux/amd64,linux/arm64 \
     -t [AWS_ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com/plantasia:latest \
     --push .
   ```

2. Create MongoDB credentials:
   ```bash
   kubectl create secret generic mongodb-credentials \
     --from-literal=MONGODB_PASSWORD='your-password-here'
   ```

3. Create ConfigMap:
   ```bash
   kubectl create configmap plantasia-config \
     --from-literal=MONGODB_USER=admin \
     --from-literal=MONGODB_HOST=your-mongodb-host
   ```

4. Deploy to Kubernetes:
   ```bash
   kubectl apply -f kubernetes/plantasia.yaml
   ```

## Environment Variables

- `MONGODB_USER`: MongoDB username
- `MONGODB_PASSWORD`: MongoDB password
- `MONGODB_HOST`: MongoDB host address

## API Endpoints

- `POST /api/water`: Record a watering event
  ```json
  {
    "name": "Optional user name"
  }
  ```

- `GET /api/water`: Get all watering events

## Infrastructure Setup

### Terraform

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

2. Review the infrastructure changes:
   ```bash
   terraform plan
   ```

3. Apply the infrastructure:
   ```bash
   terraform apply
   ```

The Terraform configuration creates:
- EKS cluster with node groups
- VPC with public and private subnets
- EC2 instance for MongoDB
- Security groups and IAM roles
- ECR repository for container images

### MongoDB Instance:
- EC2 instance running MongoDB
- Security group allowing port 27017
- Authentication enabled

### Kubernetes:
- EKS cluster
- ConfigMap for MongoDB connection
- Secret for MongoDB password
- Deployment with 2 replicas
- LoadBalancer service

## Project Structure
```
.
├── main.go                 # Main application file
├── internal/              
│   ├── handlers/          # HTTP handlers
│   └── models/            # Data models
├── static/                # Frontend files
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Variable definitions
│   └── outputs.tf        # Output definitions
├── kubernetes/            # Kubernetes manifests
│   └── plantasia.yaml    # Deployment configuration
├── Dockerfile            # Container build instructions
├── go.mod               # Go module file
└── README.md            # This file
```

## CI/CD

The project uses GitHub Actions for continuous integration and deployment. On push to the main branch:
1. Runs tests
2. Builds Docker image
3. Pushes to AWS ECR
4. Updates EKS deployment

Required GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `EKS_CLUSTER_NAME`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request