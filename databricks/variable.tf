variable "cluster_name" {
  description = "A name for the cluster."
  type        = string
  default     = "My Cluster"
}

variable "cluster_autotermination_minutes" {
  description = "How many minutes before automatically terminating due to inactivity."
  type        = number
  default     = 60
}

variable "cluster_min_workers" {
  description = "The number of workers."
  type        = number
  default     = 1
}

variable "cluster_max_workers" {
  description = "The max number of workers."
  type        = number
  default     = 4
}

variable "cross_role_arn" {
  description = "arn of the role created for cross account permission"
  type = string
  
}