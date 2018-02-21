# Requirements

- [Terraform](https://www.terraform.io/)
- [Vagrant](https://www.vagrantup.com/)
- Account on [AWS](https://aws.amazon.com/)
- [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)


# Init

## Set up VPC on AWS for VM

    local$ cd terraform
    local$ cp terraform.tfvars.template terraform.tfvars
    local$ # Set variables in terraform.tfvars.
    local$ terraform init
    local$ terraform apply


## Set password for Jupyter

    local$ cd provisioning-scripts
    local$ cp jupyter-password.txt.template jupyter-password.txt
    local$ # Edit jupyter-password.txt to set your desired password.


# Usage

## Spin up, connect to, halt, and destroy VM on AWS

    local$ ./myvagrant.bash up
    local$ ./myvagrant.bash ssh
    local$ ./myvagrant.bash halt
    local$ ./myvagrant.bash destroy


## Connect to Jupyter notebook on VM on AWS

    local$ ./myvagrant.bash up
    local$ ./forward_port_for_jupyter.bash

Then point your browser to https://127.0.0.1:8157 to connect to the Jupyter
server on the VM on AWS.
