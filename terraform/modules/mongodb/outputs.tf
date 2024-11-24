output "mongodb_instance_id" {
  description = "ID of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.id
}

output "mongodb_private_ip" {
  description = "Private IP of the MongoDB instance"
  value       = aws_instance.mongodb.private_ip
}

output "mongodb_public_ip" {
  description = "Public IP of the MongoDB instance"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_connection_string" {
  description = "MongoDB connection string"
  value       = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${aws_instance.mongodb.private_ip}:27017/${var.database_name}"
  sensitive   = true
}

output "backup_bucket_name" {
  description = "Name of the S3 bucket for MongoDB backups"
  value       = aws_s3_bucket.mongodb_backup.id
} 