variable "databricks_account_id" {
  description = "Account ID of the main databricks"
  type        = number
  default     = 414351767826

}

variable "external_id" {
  description = "TotalEnergies' Databricks account ID(to be changed)"
  type        = string
  default     = "15287f33-e124-49b2-ad5d-6e4c066799a6"
}

variable "vpc_id" {
  description = "VPC ID of your landing zone"
  type        = string
}

variable "region" {
  default = "eu-central-1"
}

variable "security_group_id" {
  description = "security group created for network deployment"
  type        = string
}