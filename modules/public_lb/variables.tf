variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name" {
  description = "Name used for all resources"
  type        = string
}

variable "target_ids" {
  description = "List of the terget ids"
  type        = list(string)
}

variable "security_groups_ids" {
  description = "List of the security groups ids for LB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of the subnet ids for LB"
  type        = list(string)
}

variable "certificate_domain" {
  description = "Certificate domain name used for LB listener"
  type        = string
}

variable "ssl_policy" {
  description = "Policy name used in the https LB listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "tags" {
  description = "Additional tags. Name tag is generated from name variable"
  type        = map(string)
}
