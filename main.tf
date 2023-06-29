# create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# create subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "MySubnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Attach Internet Gateway to VPC
#resource "aws_internet_gateway_attachment" "my_attachment" {
#  vpc_id                 = aws_vpc.my_vpc.id
#  internet_gateway_id    = aws_internet_gateway.my_igw.id
#  force_detach           = true 
#}

# Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyRouteTable"
  }
}

# Create Route
resource "aws_route" "my_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create Security Group
resource "aws_security_group" "my_security_group" {
  name        = "MySecurityGroup"
  description = "My custom security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {

  ami                  = data.aws_ami.ubuntu.id
  instance_type         = "t2.micro"
  key_name              = "ec2-basic-study-pem"
  monitoring            = true
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id             = aws_subnet.my_subnet.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
