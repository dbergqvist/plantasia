locals {
  cluster_name = "${var.environment}-plantasia"
  
  tags = {
    Environment = var.environment
    Project     = "plantasia"
    Terraform   = "true"
    ManagedBy   = "terraform"
  }
} 