//variable "aws_secret_key" {}
//variable "aws_access_key" {}
variable "region" {
  default = "us-east-1"
}
variable "mykey" {
  default = "petclinic-rancher-dmr"
}
variable "tags" {
  default = "petclinic-rancher-server-dmr"
}
variable "myami" {
  description = "ubuntu 22.04 LTS ami"
  default = "ami-0c7217cdde317cfec"
}
variable "instancetype" {
  default = "t3a.medium"
}

variable "secgrname" {
  default = "rancher-server-sec-gr-dmr"
}

variable "domain-name" {
  default = "*.perfectlectures.us"
}

variable "rancher-subnet" {
  default = "subnet-042d2f40a9e801878"
}

variable "hostedzone" {
  default = "perfectlectures.us"
}

variable "tg-name" {
  default = "clarus-rancher-http-80-tg-dmr"
}

variable "alb-name" {
  default = "petclinic-rancher-alb-dmr"
}

variable "controlplane-policy-name" {
  default = "petclinic_policy_for_rke-controlplane_role-dmr"
}

variable "worker-policy-name" {
  default = "petclinic_policy_for_rke_etcd_worker_role-dmr"
}

variable "rancher-role" {
  default = "petclinic_role_rancher-dmr"
}

variable "controlplane-attach" {
  default = "petclinic_attachment_for_rancher_controlplane"
}

variable "worker-attach" {
  default = "petclinic_attachment_for_rancher_controlplane"
}