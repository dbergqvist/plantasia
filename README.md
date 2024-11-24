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
   docker buildx build --platform linux/amd64,linux/arm64 \
     -t 476114158430.dkr.ecr.eu-north-1.amazonaws.com/plantasia:latest \
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

1. MongoDB Instance:
   - EC2 instance running MongoDB
   - Security group allowing port 27017
   - Authentication enabled

2. Kubernetes:
   - EKS cluster
   - ConfigMap for MongoDB connection
   - Secret for MongoDB password
   - Deployment with 2 replicas
   - LoadBalancer service

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License

Copyright (c) 2024 Plantasia

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.