variable "bucket_name" {
  description = "Name of your databricks bucket"
  type        = string
  default     = "databricks-bucket"

}

variable "databricks_account_id" {
  description = "Account ID of the main databricks"
  type        = number
  default     = 414351767826

}