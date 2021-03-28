variable "project" {
  description = "The name of the project which should be used as a prefix for all resources in this example"
  default     = "webserver"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created"
  default     = "westeurope"
}

variable "vm_count" {
  description = "The number of Virtual Machines that are hosting the application"
  default     = 2
}

variable "fault_domain_count" {
  description = "The number of fault domains that are used for the virtual machines"
  default     = 2
}

variable "vm_username" {
  description = "The username for accessing the virtual machines"
  default     = "webserver-admin"
}

variable "vm_password" {
  description = "The password for accessing the virtual machines"
}

variable "image_id" {
  description = "The id of the image used to provision the virtual machines"
  default     = "/subscriptions/3b90dd9d-06bd-4e87-938b-ee80444ba20e/resourceGroups/webserver-images/providers/Microsoft.Compute/images/webserver-image"
}
