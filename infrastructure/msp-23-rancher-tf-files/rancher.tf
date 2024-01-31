terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "tls" {}

resource "tls_private_key" "example-dmr" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_dmr" {
  key_name   = var.mykey
  public_key = tls_private_key.example-dmr.public_key_openssh
}

output "private" {
  value = tls_private_key.example-dmr.private_key_pem
  sensitive = true
}

resource "aws_instance" "tf-rancher-server" {
  ami           = var.myami
  instance_type = var.instancetype
  key_name      = aws_key_pair.generated_key_dmr.key_name
  vpc_security_group_ids = [aws_security_group.tf-rancher-sec-gr-dmr.id]
  iam_instance_profile = aws_iam_instance_profile.profile_for_rancher_dmr.name
  subnet_id = var.rancher-subnet
  root_block_device {
    volume_size = 16
  }
  user_data = file("rancherdata.sh")
  tags = {
    Name = var.tags
    "kubernetes.io/cluster/petclinic-Rancher" = "owned"
  }
}

resource "aws_alb_target_group" "rancher-tg-dmr" {
  name = var.tg-name
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-f52d178f"
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    path = "/healthz"
    port = "traffic-port"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 5
    interval = 10
  }
}

resource "aws_alb_target_group_attachment" "rancher-attach-dmr" {
  target_group_arn = aws_alb_target_group.rancher-tg-dmr.arn
  target_id = aws_instance.tf-rancher-server-dmr.id
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_lb" "rancher-alb-dmr" {
  name = var.alb-name
  ip_address_type = "ipv4"
  internal = false
  load_balancer_type = "application"
  subnets = ["subnet-042d2f40a9e801878", "subnet-011635b5f528b8a5c", "subnet-027b102c209b9b85c"]
  security_groups = [aws_security_group.rancher-alb-dmr.id]
}

data "aws_acm_certificate" "cert" {
  domain = var.domain-name
  statuses = [ "ISSUED" ]
  most_recent = true
}

resource "aws_alb_listener" "rancher-listener1" {
  load_balancer_arn = aws_lb.rancher-alb-dmr.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.cert.arn
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.rancher-tg-dmr.arn
  }
}
resource "aws_alb_listener" "rancher-listener2" {
  load_balancer_arn = aws_lb.rancher-alb-dmr.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    }
}
resource "aws_iam_policy" "policy_for_rke-controlplane_role-dmr" {
  name        = var.controlplane-policy-name
  policy      = file("cw-rke-controlplane-policy.json")
}

resource "aws_iam_policy" "policy_for_rke_etcd_worker_role-dmr" {
  name        = var.worker-policy-name
  policy      = file("cw-rke-etcd-worker-policy.json")
}

resource "aws_iam_role" "role_for_rancher-dmr" {
  name = var.rancher-role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "dmr-petclinic_role_controlplane_rke"
  }
}

resource "aws_iam_policy_attachment" "attach_for_rancher1_dmr" {
  name       = var.controlplane-attach
  roles      = [aws_iam_role.role_for_rancher-dmr.name]
  policy_arn = aws_iam_policy.policy_for_rke-controlplane_role-dmr.arn
}

resource "aws_iam_policy_attachment" "attach_for_rancher2_dmr" {
  name       = var.worker-attach
  roles      = [aws_iam_role.role_for_rancher-dmr.name]
  policy_arn = aws_iam_policy.policy_for_rke_etcd_worker_role-dmr.arn
}

resource "aws_iam_instance_profile" "profile_for_rancher_dmr" {
  name  = var.rancher-role
  role = aws_iam_role.role_for_rancher-dmr.name
}


data "aws_route53_zone" "dns" {
  name = var.hostedzone  
}

resource "aws_route53_record" "arecord" {
  name = "ranchero.${data.aws_route53_zone.dns.name}"
  type = "A"
  zone_id = data.aws_route53_zone.dns.zone_id
  alias {
    name = aws_lb.rancher-alb-dmr.dns_name
    zone_id = aws_lb.rancher-alb-dmr.zone_id
    evaluate_target_health = true
  }
}

resource "null_resource" "privatekey" {
  depends_on = [tls_private_key.example-dmr]
  provisioner "local-exec" {
    command = "terraform output -raw private > ~/.ssh/${var.mykey}.pem"
  }
    provisioner "local-exec" {
      command = "cd ~/.ssh/ && chmod 400 ${var.mykey}.pem"
    }
}