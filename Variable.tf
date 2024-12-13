variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]
}
