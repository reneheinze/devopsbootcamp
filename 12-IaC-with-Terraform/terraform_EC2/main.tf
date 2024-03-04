provider "aws" {
    region = "eu-central-1"
}

#variables defined in terraform.tfvars
variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone{}
variable env_prefix {}
variable my_ip {}
variable instance_type{}
variable public_key_location{}

#my resource aws_vpc.myapp-vpc
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
# String Interpolation. Variable Value (-vpc) and String (env_prefix) glued together.
        Name: "${var.env_prefix}-vpc"
    }
}

#my resource aws_subnet.myapp-subnet-1
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
    tags = {
# String Interpolation. Variable Value (-vpc) and String (env_prefix) glued together.
        Name: "${var.env_prefix}-subnet"
    }
}

/*# my resource aws_route_table.myapp-route-table
resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb" 
    }
}*/

resource "aws_default_route_table" "main-rtb"{
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb" 
    }
}


#resource "aws_security_group" "myapp-sg" {
#    name = "myapp-sg"

resource "aws_default_security_group" "default_sg" {
    vpc_id = aws_vpc.myapp-vpc.id
# Ingress is for INCOMING traffic. from & to = opening a range on that server. We need only port 22
    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        # Who is allowed to access the resource on port 22? (Only Me 😀 ) 
        cidr_blocks = [var.my_ip]
    } 
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        # Who is allowed to access the resource on port 22?
        cidr_blocks = ["0.0.0.0/0"]
    }
# Egress is for OUTGOING traffic
    egress {
        # 0 = any Port
        from_port = 0
        to_port = 0
        # -1 = any Protokoll
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-sg" 
    }


}


# my resource aws_internet_gateway.myapp-igw
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw" 
    }
}


data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# my resource aws_instance
resource "aws_instance" "myapp-server" {
    # required attributes
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    
    # optional attributes (vpc_security_group_ids is a list)
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default_sg.id]
    availability_zone = var.avail_zone
    
    # I want a public IP adress for the server
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name: "${var.env_prefix}-server"
    }
}

# ssh-key
resource "aws_key_pair" "ssh-key"{
    key_name = "server-key"
    public_key = file(var.public_key_location)

}


/*# my resource aws_route_table_association
resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}*/

/*output "igw" {
    value = aws_internet_gateway.myapp-igw.id
}*/

/*output "rtb" {
    value = aws_route_table.myapp-route-table.id
}*/

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}