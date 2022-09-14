provider "aws" {
  profile = "default" 
  region = "ap-east-1"
}

resource "aws_subnet" "tf_subnet_public" {
  vpc_id = "vpc-0e4025fa6cb2edc0c"
  availability_zone = "ap-east-1a"
  cidr_block = "192.168.128.0/24"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "vpc-0e4025fa6cb2edc0c"

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_jenkins" {
  name        = "allow_jenkins"
  description = "Allow jenkins inbound traffic"
  vpc_id      = "vpc-0e4025fa6cb2edc0c"

  ingress {
    description      = "HTTP from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id      = "vpc-0e4025fa6cb2edc0c"

    ingress {
        description      = "SSH from VPC"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    } 
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.tf_subnet_public.id
  route_table_id = "rtb-08306a8498eaea447"
}


resource "aws_instance" "jenkins" {
  ami           = "ami-0f3278a64fd98697c"
  instance_type = "t3.medium"
  subnet_id   = aws_subnet.tf_subnet_public.id
  key_name = "huatq2"
#  user_data = "${file("app_install.sh")}"
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow_jenkins.id, aws_security_group.allow_ssh.id]
  tags = {
    Name = "HuaTQ_Jenkins"
  }
}


resource "aws_instance" "web" {
  ami           = "ami-0ecb6d8435affe2b6"
  instance_type = "t3.micro"
  subnet_id   = aws_subnet.tf_subnet_public.id
  key_name = "huatq2"
#  user_data = "${file("app_install.sh")}"
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  tags = {
    Name = "HuaTQ_web"
  }
}
  
