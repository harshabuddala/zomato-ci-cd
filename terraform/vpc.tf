module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "bms-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  # Public Subnets for simplicity as requested by user
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # Private subnets disabled to save NAT Gateway costs and complexity
  # This makes the setup "Public Node" style
  enable_nat_gateway = false
  enable_vpn_gateway = false
  
  # Required for nodes to register
  map_public_ip_on_launch = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
