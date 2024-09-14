variable "name" {
  type        = string
  description = "Name of the group"
}

variable "launch_template_id" {
  type        = string
  description = "ID of the launch template"
}

variable "port" {
  type        = number
  description = "value of the port for the traffic"
  default     = 80
}

variable "protocol" {
  type        = string
  description = "Protocol of the traffic"
  default     = "HTTP"
}

variable "vpc_id" {
  type        = string
  description = "VPC id to be in"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of azs for the asg to be in"
}

variable "load_balancer_type" {
  type        = string
  default     = "application"
  description = "Type of the load balanver to configure"
}

variable "private" {
  type        = bool
  description = "Internet facing or internal"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets of the alb to be deployed in "
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups for the lb"
}

variable "instances_subnets" {
  type        = list(string)
  description = "Subnets of the instances for the asg"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the string for the HTTPS"
  default     = ""
  validation {
    condition     = var.protocol != "HTTPS" || (var.protocol == "HTTPS" && var.certificate_arn != "")
    error_message = "You must provide a valid certificate_arn when protocol is HTTPS."
  }
}

variable "path" {
  default     = "/"
  type        = string
  description = "Path fo the health check"
}

variable "port_tg" {
  description = "Port of the target group"
  type        = number
}

variable "bucket_id" {
  type        = string
  description = "Name of the bucket to store logs in"
}

variable "bucket_prefix" {
  type        = string
  description = "Name of the folder to store the logs"
}

variable "protocol_tg" {
  type = string
  description = "Protocol of the tg"
}
