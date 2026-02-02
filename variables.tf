variable "region" {
  default = "East US"
}

variable "vnet_space" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "is_public" {
  type = bool
  default = false
}

variable "container_name" {
  type = string
  default = "default"
}

variable "dept_names" {
  type = list(string)
  default = ["finance","marketing","legal"]
}


# variable "subnet_names" {
#   type = list(string)
#   default = ["web","app","db"]
# }
variable "subnet_names" {
  type = map(string)
  default = {
    "web" = "10.0.1.0/24"
    "app" = "10.0.2.0/24"
    "db"  = "10.0.3.0/24"
  }
}
