Endava School of Devops Terraform Demo
=========

This demo code creates an AWS EKS deployed wordpress application with its own Route53 domain name. 

PreRequisites
------------

 - Registered Domain name in AWS Route53
 - Ansible
 - community.kubernetes Galaxy role (ansible-galaxy collection install community.kubernetes)
 - Installed and configured AWS CLI.
 - Terraform
 - Create your own tf/terraform.tfvars file with at least 3 vars - registered_domain, external_dns, external_ip. See tf/variables.tf for a description.

How it works
----------------

Terraform provisions a VPC, Subnets, Security Groups, IAM Policies, IAM Roles, EKS Cluster, EKS Node Groups and a EC2 Instance.
Then it launches ansible which connects to the EC2 instance which installs and configures kubernets and helm. 
Ansible then creates a helm release for bitnami/external-dns which is a solution that allows future K8s services of type LoadBalancer or Ingress to have a dynamically provisioned Route53 DNS name (public). 
Another helm release of bitnami/wordpress is then created which uses external-dns to register a record for itself in Route53 with the record name being something we've chosen for it in the variables. 

How to deploy
----------------
```
cd ./tf && terraform init && terraform apply
```
How to destroy
----------------

```
ssh ec2-user@<jump_server_public_ip>
sudo helm delete wordpress && sleep 600
logout 
cd ./tf && terraform destroy
```

WARNING!
----------------
AWS charges will occur!