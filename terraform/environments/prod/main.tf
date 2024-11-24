provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name            = "${var.environment}-plantasia-vpc"
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  cluster_name        = local.cluster_name
  
  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = local.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  environment         = var.environment

  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  node_group_desired_size = var.node_group_desired_size
  
  tags = local.tags
}

module "mongodb" {
  source = "../../modules/mongodb"

  environment      = var.environment
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  public_subnet_id = module.vpc.public_subnet_ids[0]
  
  ami_id          = var.mongodb_ami_id
  instance_type   = var.mongodb_instance_type
  ssh_key_name    = var.ssh_key_name
  
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
  database_name    = var.database_name
  
  tags = local.tags
} 