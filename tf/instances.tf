data "aws_ssm_parameter" "latest_amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jump_server" {
  key_name   = "jump_server"
  public_key = tls_private_key.ssh.public_key_openssh

  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh.private_key_pem}\" > ~/.ssh/id_rsa; chmod 400 ~/.ssh/id_rsa"
  }
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh.public_key_pem}\" > ~/.ssh/id_rsa.pub; chmod 400 ~/.ssh/id_rsa.pub"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/id_rsa"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/id_rsa.pub"
  }

  tags = local.common_tags

}

resource "aws_instance" "jump_server" {
  ami                         = data.aws_ssm_parameter.latest_amazon_linux.value
  instance_type               = var.instance-type
  subnet_id                   = aws_subnet.eks_subnet[0].id
  #vpc_security_group_ids      = [aws_security_group.EKS_security_group.id]
  vpc_security_group_ids      = [module.EKS_security_group.this_security_group_id	]
  associate_public_ip_address = true
  key_name                    = "jump_server"
  tags = merge(
    local.common_tags,
    map(
      "Name", "jump_server"
    )
  )

  provisioner "local-exec" {
    command = <<EOF
aws  ec2 wait instance-status-ok  --instance-ids ${self.id} --region ${var.aws-region} \
&& ansible-playbook -i "${self.public_ip}," --extra-vars '\
eks_ca_data=${aws_eks_cluster.demo_eks.certificate_authority[0].data} \
endpoint=${aws_eks_cluster.demo_eks.endpoint} \
eks_cluster_arn=${aws_eks_cluster.demo_eks.arn} \
aws_region=${var.aws-region}  \
cluster_name=${aws_eks_cluster.demo_eks.name} \
external_ip=${var.external_ip} \
external_dns=${var.external_dns} \
dns_zone_id=${data.aws_route53_zone.selectedZone.zone_id} \
registered_domain=${var.registered_domain} \
' ../ansible/aws_helm_deploy/playbook.yaml
EOF
  }


  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo helm del wordpress"
  #   ]
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file("~/.ssh/id_rsa")
  #     host        = self.public_ip
  #   }
  # }


  depends_on = [aws_eks_cluster.demo_eks,
    aws_eks_node_group.eks_node_group
  ]
}

output "jump_server_public_ip" {
  value = aws_instance.jump_server.public_ip
}


data "aws_route53_zone" "selectedZone" {
  name         = "${var.registered_domain}."
  private_zone = false
}


output "URL" {
  value = var.external_dns
}


# resource "aws_security_group" "EKS_security_group" {
#   name        = "allow_ssh"
#   description = "Allow ssh inbound traffic from home PC"
#   vpc_id      = aws_vpc.eks_vpc.id

#   ingress {
#     description = "SSH from Home"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.external_ip]
#   }

#   ingress {
#     description = "allow internal communication"
#     from_port   = 0
#     self        = true
#     to_port     = 0
#     protocol    = "-1"
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(
#     local.common_tags,
#     map(
#       "Name", "allow_ssh"
#     )
#   )

# }



module "EKS_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 3.0"
  vpc_id      = aws_vpc.eks_vpc.id
  name = "allow_ssh"

  ingress_cidr_blocks = [var.external_ip]

  tags = local.common_tags

}