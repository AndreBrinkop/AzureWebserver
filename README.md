# Azure Webserver: Deploying a scalable IaaS web server in Azure

### Introduction
This project contains starter Packer and Terraform templates to deploy a customizable, scalable web server in Azure.
The Packer template is used to create a machine image that contains and serves a simple web application.
The Terraform template can be used to create and deploy the necessary hardware.
The created resources will include a Load Balancer and a set of virtual machines that will run the web application.

### Dependencies
1. Create an  [Azure Account](https://portal.azure.com)
1. [Register a new App](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps) within the Azure Portal and create an App secret
1. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
1. Install [Packer](https://www.packer.io/downloads)
1. Install [Terraform](https://www.terraform.io/downloads.html)

### Getting Started
1. Clone this repository
1. Export the following environment variables that are needed for Packer and Terraform to communicate with Azure.
    - ARM_SUBSCRIPTION_ID - Can be found in your Subscription in the Azure Portal
    - ARM_TENANT_ID - Can be found in your App Registration in the Azure Portal
    - ARM_CLIENT_ID - Can be found in your App Registration in the Azure Portal
    - ARM_CLIENT_SECRET - Can be found in the secret of your App Registration in the Azure Portal
    
### Instructions
##### *Optional*: Tagging Policy
This project includes a Policy for Azure that can be used to require resources that are created in your account to have at least one associated tag. You could add this policy to your subscription like this:
 ```
az policy definition create --name tagging-policy --mode indexed --rules tagging-policy-rules.json
az policy assignment create --policy tagging-policy
```
##### Create Packer Image
1. Create a `webserver-images` Resource Group for the Packer Image: `az group create -l westeurope -n webserver-images`
1. Make sure you set up your credentials correctly as described in [getting started](### Getting Started)
1. Build the image: `packer build packer-image/server.json`

##### Deploy resources using Terraform
1. Make sure you set up your credentials correctly as described in [getting started](### Getting Started)
1. Run `terraform plan --out terraform/solution.plan terraform/` to see what resources Terraform would create. You will be prompted to specify a password for the VMs that will be created.
1. Run `terraform apply terraform/solution.plan terraform/` to create and deploy the resources. If everything runs successfully Terraform will print out the public IP for our web application.
`

### Output
After you created a Packer image and deployed the infrastructure using this image you will have a Load Balancer running that balances the traffic between two virtual machines that run your web application.
The output of the `terraform apply` command will include the IP address of your Load Balancer which can be used to access your application. The output will look similar to this example:
```
Outputs:

load_balancer_ip_address = "52.233.158.138"
```
In this example `52.233.158.138` can be used in your browsers URL field to access the application.