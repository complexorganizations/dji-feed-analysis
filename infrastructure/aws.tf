// Create a VPC in aws.
resource "aws_vpc" "vpc" {
  cidr_block                           = "10.0.0.0/16"
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  assign_generated_ipv6_cidr_block     = true
  enable_network_address_usage_metrics = true
  tags = {
    Name = "dji-feed-analysis-vpc-0-us-east-1"
  }
}

// Create a VPC flow log role assume policy
data "aws_iam_policy_document" "vpc_flow_log_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

// Create a VPC flow log role
resource "aws_iam_role" "vpc_flow_log_role" {
  name               = "dji-feed-analysis-vpc-flow-log-role-0-us-east-1"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_role_assume_policy.json
  tags = {
    Name = "dji-feed-analysis-vpc-flow-log-role-0-us-east-1"
  }
}

// Enable vpc flow logs
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

// Create a key using AWS KMS
resource "aws_kms_key" "key_0" {
  description                        = "Create a key using AWS KMS to encrypt and decrypt files."
  key_usage                          = "ENCRYPT_DECRYPT"
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  is_enabled                         = true
  enable_key_rotation                = true
  multi_region                       = true
  tags = {
    // {project-name}-kms-{0}-{us-east-1a}
    Name = "dji-feed-analysis-kms-0-us-east-1a"
  }
}

// Create a cloudwatch log group
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "dji-feed-analysis-vpc-flow-log-group-0-us-east-1"
  retention_in_days = 30
  tags = {
    Name = "dji-feed-analysis-vpc-flow-log-group-0-us-east-1"
  }
  kms_key_id = aws_kms_key.key_0.arn
}

// Create 6 subnet (3 private / 3 public)
resource "aws_subnet" "subnet_0" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private-subnet-"
  }
}
