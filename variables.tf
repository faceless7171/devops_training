variable "environment" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "cidr_block" {
  type = string
}
