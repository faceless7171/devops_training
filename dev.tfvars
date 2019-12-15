environment = "dev"

availability_zones = ["us-east-1a", "us-east-1b"]

subnets = {
  public_a = {
    name                    = "nsoroka-training-sn-public-a"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
    cidr_block              = "10.0.0.0/24"
  }
  public_b = {
    name                    = "nsoroka-training-sn-public-b"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true
    cidr_block              = "10.0.1.0/24"
  }
  private_a = {
    name                    = "nsoroka-training-sn-private-a"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false
    cidr_block              = "10.0.10.0/24"
  }
  private_b = {
    name                    = "nsoroka-training-sn-private-b"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = false
    cidr_block              = "10.0.11.0/24"
  }
  private_back_a = {
    name                    = "nsoroka-training-sn-private-back-a"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false
    cidr_block              = "10.0.15.0/24"
  }
  private_back_b = {
    name                    = "nsoroka-training-sn-private-back-b"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = false
    cidr_block              = "10.0.16.0/24"
  }
  private_db_a = {
    name                    = "nsoroka-training-sn-private-db-a"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false
    cidr_block              = "10.0.20.0/24"
  }
  private_db_b = {
    name                    = "nsoroka-training-sn-private-db-b"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = false
    cidr_block              = "10.0.21.0/24"
  }
}
