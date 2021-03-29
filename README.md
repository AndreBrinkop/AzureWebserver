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
    - `ARM_SUBSCRIPTION_ID` - Can be found in your Subscription in the Azure Portal
    - `ARM_TENANT_ID` - Can be found in your App Registration in the Azure Portal
    - `ARM_CLIENT_ID` - Can be found in your App Registration in the Azure Portal
    - `ARM_CLIENT_SECRET` - Can be found in the secret of your App Registration in the Azure Portal
    
### Instructions
##### *Optional*: Tagging Policy
This project includes a Policy for Azure that can be used to require resources that are created in your account to have at least one associated tag. You could add this policy to your subscription like this:
 ```
az policy definition create --name tagging-policy --mode indexed --rules tagging-policy-rules.json
az policy assignment create --policy tagging-policy
```
##### Create Packer Image
1. Create a `webserver-images` Resource Group for the Packer Image: `az group create -l westeurope -n webserver-images`
1. Make sure you set up your credentials correctly as described in [getting started](#getting-started).
1. Build the image: `packer build packer-image/server.json`

##### Deploy resources using Terraform
1. Make sure you set up your credentials correctly as described in [getting started](#getting-started).
1. Run `terraform plan --out terraform/solution.plan terraform/` to see what resources Terraform would create. You will be prompted to specify a password for the VMs that will be created and the image id that is used to provision the VMs.
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

### Customization
##### Packer
The Packer template contains a variable to specify the project name. This variable is used to create the image name (`projectname-image`) and specify the name of the resource group (`projectname-images`) of the created image.
You can update this variable either directly at the beginning of the `packer-image/server.json` file in the `variables` section or by passing the `-var 'key=value'` parameter while running the `packer build` command.
Please make sure the resource group you want to store your image in exists before running `packer build`.

##### Terraform
The Terraform template contains the following variables that can be adjusted for your needs:
- `project` - The name of the project which should be used as a prefix for all resources in this example (default: `webserver`)
- `location` - The Azure Region in which all resources in this example should be created (default: `westeurope`)
- `vm_count` - The number of Virtual Machines that are hosting the application (default: `2`)
- `fault_domain_count` - The number of fault domains that are used for the virtual machines (default: `2`)
- `vm_username` - The username for accessing the virtual machines (default: `webserver-admin`)
- `vm_password` - The password for accessing the virtual machines"
- `image_id` - The id of the image used to provision the virtual machines"

To modify any of these values either update their default directly in the `terraform/variables.tf` file or include the `-var 'foo=bar'` parameter while running the `terraform plan` command.
Alternatively you could also store your values in a `terraform.tfvars` file and pass it to the plan command using the `-var-file=foo` parameter.
