# S3 bucket for MongoDB backups
resource "aws_s3_bucket" "mongodb_backup" {
  bucket = "${var.environment}-mongodb-backup-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Enable versioning for backup safety
resource "aws_s3_bucket_versioning" "mongodb_backup" {
  bucket = aws_s3_bucket.mongodb_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# EC2 Instance for MongoDB
resource "aws_instance" "mongodb" {
  ami           = "ami-0989fb15ce71ba39e"
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  key_name      = var.ssh_key_name

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.mongodb_profile.name
  vpc_security_group_ids = [aws_security_group.mongodb.id]

  user_data = <<-EOF
              #!/bin/bash
              
              # Update and install required packages
              apt-get update
              apt-get install -y snapd
              
              # Install and start SSM agent
              snap install amazon-ssm-agent --classic
              snap start amazon-ssm-agent
              
              # Install MongoDB
              wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
              echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
              apt-get update
              apt-get install -y mongodb-org
              
              # Start MongoDB
              systemctl start mongod
              systemctl enable mongod
              
              # Configure MongoDB
              echo "security:
                authorization: enabled" >> /etc/mongod.conf
              
              # Restart MongoDB with new config
              systemctl restart mongod
              EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-mongodb"
    }
  )
}

# Security Group for MongoDB
resource "aws_security_group" "mongodb" {
  name        = "${var.environment}-mongodb-sg"
  description = "Security group for MongoDB server"
  vpc_id      = var.vpc_id

  # SSH access from anywhere (you might want to restrict this)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr
  }

  # MongoDB access from VPC only
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# IAM Role and Instance Profile
resource "aws_iam_role" "mongodb_role" {
  name = "${var.environment}-mongodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "mongodb_policy" {
  name = "${var.environment}-mongodb-policy"
  role = aws_iam_role.mongodb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ec2:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.mongodb_backup.arn,
          "${aws_s3_bucket.mongodb_backup.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "mongodb_profile" {
  name = "${var.environment}-mongodb-profile"
  role = aws_iam_role.mongodb_role.name
}

# Add these policies to the MongoDB role
resource "aws_iam_role_policy_attachment" "mongodb_ssm" {
  role       = aws_iam_role.mongodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "mongodb_ssm_patch" {
  role       = aws_iam_role.mongodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
} 