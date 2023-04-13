variable "region" {
  default = "eu-central-1"
}

variable "route_table_id" {
  default = "rtb-01a7e7edcd1718850"
}

variable "dabricks_subnet1" {
  description = "The first of the two Databricks subnet in 100.0.0.0/16 range"
}

variable "dabricks_subnet2" {
  description = "The second of the two Databricks subnet in 100.0.0.0/16 range"
}
variable "nat_subnet" {
  description = "subnet for the nat gateway in 10.0.0.0/16 "
}

variable "vpc_cidr_block" {
  default = "100.64.0.0/16"
}

variable "odb_vpcid" {
  description = "VPC ID of your landing zone"
  type        = string
}

variable "availabilities_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "endpointscc_databricks" {
  description = "endpoint for workspace and Secure Cluster connectivity relay"
  type        = string
  default     = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
}
variable "endpointrest_databricks" {
  description = "endpoint for workspace Rest API"
  type        = string
  default     = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
}