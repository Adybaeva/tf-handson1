resource "aws_vpc" "batch-14-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Batch-14-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "puclic-subnet-1a" {
  vpc_id                  = aws_vpc.batch-14-vpc.id
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "puclic-subnet-1a"
  }
}

resource "aws_subnet" "puclic-subnet-1b" {
  vpc_id                  = aws_vpc.batch-14-vpc.id
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "puclic-subnet-1b"
  }
}

resource "aws_subnet" "private-subnet-1a" {
  vpc_id                  = aws_vpc.batch-14-vpc.id
  cidr_block              = "10.0.128.0/18"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-subnet-1a"
  }
}

resource "aws_subnet" "private-subnet-1b" {
  vpc_id                  = aws_vpc.batch-14-vpc.id
  cidr_block              = "10.0.192.0/18"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet-1b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.batch-14-vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.puclic-subnet-1a.id

  tags = {
    Name = "natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.batch-14-vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

resource "aws_route_table_association" "public_rtb-to-public-1a" {
  subnet_id      = aws_subnet.puclic-subnet-1a.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "public_rtb-to-public-1b" {
  subnet_id      = aws_subnet.puclic-subnet-1b.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.batch-14-vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-rtb"
  }

  depends_on = [aws_nat_gateway.natgw]
}

resource "aws_security_group" "ec2-sgrp" {
  name = "ec2-sgrp"
  vpc_id = aws_vpc.batch-14-vpc.id

  ingress {
    description = "Open port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    description = "Open port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sgrp"
  }
}

data "aws_ami" "amazon_lunix-2023" {
    most_recent = true

    filter {
      name = "image-id"
      values = ["ami-05576a079321f21f8"]

    }

    filter {
      name = "owner-alias"
      values = ["amazon"]
    }
}

data "aws_key_pair" "ssh-key" {
    key_name = "tentek"
}

resource "aws_instance" "public-1a-ec2" {
    ami = data.aws_ami.amazon_lunix-2023.id
    instance_type = "t2.micro"
    key_name = data.aws_key_pair.ssh-key.key_name
    vpc_security_group_ids = [aws_security_group.ec2-sgrp.id]
    subnet_id = aws_subnet.puclic-subnet-1a.id
    user_data = file("./user_data.sh")
  
    
    tags = {
      Name ="puclic-1a-ec2"
    }
    depends_on = [ aws_internet_gateway.igw, aws_security_group.ec2-sgrp ]
}

resource "aws_instance" "public-1b-ec2" {
    ami = data.aws_ami.amazon_lunix-2023.id
    instance_type = "t2.micro"
    key_name = data.aws_key_pair.ssh-key.key_name
    vpc_security_group_ids = [aws_security_group.ec2-sgrp.id]
    subnet_id = aws_subnet.puclic-subnet-1b.id
    user_data = file("./user_data.sh")
  
    
    tags = {
      Name ="puclic-1b-ec2"
    }
    depends_on = [ aws_internet_gateway.igw, aws_security_group.ec2-sgrp ]
}