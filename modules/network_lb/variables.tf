variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_port" {
  description = "target port"
  type = number
}

variable "internal" {
  description = "Indicate is LB is internal or not"
  type = bool
}

variable "name" {
  description = "Name used for all resources"
  type        = string
}

variable "target_ids" {
  description = "List of the terget ids"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of the subnet ids for LB"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags. Name tag is generated from name variable"
  type        = map(string)
}
