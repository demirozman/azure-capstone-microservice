  #!/bin/bash
  yum update -y
  hostnamectl set-hostname NexusServerOfPetclinic
  yum install docker -y
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
  newgrp docker
  docker volume create --name nexus-data
  docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3