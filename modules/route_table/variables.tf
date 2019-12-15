variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name" {
  description = "Name used for all resources"
  type        = string
}

variable "cidr_block" {
  description = "cidr block"
  type        = string
}

variable "gateway_id" {
  description = "gateway id if any"
  type        = string
  default     = null
}

variable "instance_id" {
  description = "instance id if any"
  type        = string
  default     = null
}

variable "associations_subnet_ids" {
  description = "list of the assotiated subnet ids"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags. Name tag is generated from name variable"
  type        = map(string)
}
