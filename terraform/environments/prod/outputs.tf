output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "mongodb_connection_string" {
  description = "MongoDB connection string"
  value       = module.mongodb.mongodb_connection_string
  sensitive   = true
}

output "mongodb_public_ip" {
  description = "Public IP of MongoDB instance"
  value       = module.mongodb.mongodb_public_ip
}

output "backup_bucket_name" {
  description = "Name of the S3 bucket for MongoDB backups"
  value       = module.mongodb.backup_bucket_name
} 