Max Taylor
System Administration


# automated-minecraft-server
The goal of this project is to fully automate the provisioning, configuration, and setup of your Minecraft server using the tools discussed in this course: Ansible, Terraform, Pulumi, Docker, Scripting, GitHub Actions, AWS, etc. Let me repeat it: your scripts should run without ever connecting to the AWS Management Console.


## Background

This project automates the setup of a Minecraft server hosted on an AWS EC2 instance. The goal is to deploy a playable, cloud-hosted server with minimal manual configuration.

We use **Terraform** to provision the infrastructure, including the EC2 instance and necessary networking. Then, **Ansible** is used to configure the server by installing Java and launching the Minecraft server. Instead of SSH, configuration is done through **AWS SSM (Systems Manager)** to align with project constraints that restrict user data and direct SSH access.

Once deployed, users can connect directly to the Minecraft server using its public IP address.

---

## Requirements

### Tools to Install

Make sure the following tools are installed before starting:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Git

### AWS Credentials

You’ll need an AWS account or temporary session credentials with permissions to:

- Launch EC2 instances
- Use AWS Systems Manager (SSM)
- Create IAM roles
- Configure VPC/networking

If you're using AWS Academy or temporary credentials (from the AWS Console or CloudShell), set the following environment variables in your terminal:

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_SESSION_TOKEN=your_session_tok


### Pipeline Overview:

Terraform -> EC2 Instance + IAM Role + Security Group
             |
             v
        Ansible (via AWS SSM)
             |
             v
    Minecraft Server Installed and Running
             |
             v
     Connect from Minecraft Client using EC2 Public IP

### Setup and Deployment

1. Clone the Repository:
Copy
Edit
git clone https://github.com/MaxlikeTT/automated-minecraft-server.git
cd automated-minecraft-server

2. Initialize Terraform
Navigate to the Terraform folder and initialize:

cd terraform
terraform init

3. Apply the Terraform Plan

terraform apply
(type 'Yes' when prompted.)

4. Run playbook

If needed, run the playbook to install java and the actual mc server, and config to start the server.
Navigate back to the repo root and run:

ansible-playbook -i ansible/inventory.yml ansible/playbook.yml

### How to Connect to the Minecraft Server
1. Copy the public IP of the EC2 instance from the Terraform output or AWS Console.

2. Open Minecraft → go to Multiplayer → click Add Server. OR, go to a server checker website such as https://mcsrvstat.us/ and check the status.

3. Paste the IP address and click Done.

Join the server.


### Server cleanup.
To stop AWS servers from running up a budget, run:
terraform destroy
to stop the resources.


### Notes
The .terraform/ folder and provider binaries are excluded from the repo using .gitignore, because they get huuge.

If Terraform fails to auth, verify that your AWS credentials are set correctly using 'env | grep AWS'

Instance setup with ssh

All configuration is executed via command line.

If Ansible fails to connect, check that the instance role has SSM permissions and the SSM agent is running



### Resources:
Terraform Documentation
https://developer.hashicorp.com/terraform/docs

Ansible Playbooks
https://docs.ansible.com/ansible/latest/user_guide/playbooks.html

AWS Systems Manager (SSM)
https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html

AWS CLI Configuration Guide
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

GitHub Markdown Syntax Guide
https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github

MC server checker
https://mcsrvstat.us/

Current .jar download
https://www.minecraft.net/en-us/download/server
