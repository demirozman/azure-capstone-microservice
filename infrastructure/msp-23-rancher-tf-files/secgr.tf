resource "aws_security_group" "rancher-alb-dmr" {
  name = "petclinicdt-rancher-alb-sec-gr-dmr"
  tags = {
    Name = "petclinicdt-rancher-alb-sec-gr-dmr"
    "kubernetes.io/cluster/petclinic-Rancher" = "owned"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "tf-rancher-sec-gr-dmr" {
  name = var.secgrname
  tags = {
    Name = var.secgrname
    "kubernetes.io/cluster/petclinic-Rancher" = "owned"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["172.31.72.233/32"] # BashionHostIP
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    security_groups = [aws_security_group.rancher-alb-dmr.id]
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [aws_security_group.rancher-alb-dmr.id]
  }

  ingress {
    from_port   = 6443
    protocol    = "tcp"
    to_port     = 6443
    cidr_blocks = ["172.31.72.233/32"]
  }

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    self = true
  }

  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["35.167.242.46/32", "52.33.59.17/32", "35.160.43.145/32"]
  }
  egress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 2376
    protocol    = "tcp"
    to_port     = 2376
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    self = true
  }
# Because of Docker Issue after installation is complated it should be closed
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}