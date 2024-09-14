variable "user_data" {
  description = "The script name with sh extension which will be loaded on the instacne while booting"
  type        = string
}

variable "project" {
  default     = "Rewind"
  type        = string
  description = "Name of the project"
}

variable "security_group_ids" {
  description = "Ids of the security group to be attached"
  type        = list(string)
}

variable "description" {
  type        = string
  description = "Description of the lauch template"
}

variable "template_name" {
  description = "Name of the template"
  type        = string
}

variable "policy_name" {
  type        = string
  description = "name of IAM policy to use by the instacne"
}

variable "efs_file_system_id" {
  type        = string
  description = "EFS system `to be mounted"
  default     = ""
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for the launch template"
}
