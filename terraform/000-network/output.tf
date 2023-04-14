output "vpc_id" {
  value       = var.odb_vpcid
  description = "Id of the VPC created in your VPC"
}

output "private_subnet_1" {
  value       = aws_subnet.databricksubnet_1.id
  description = "Id of the public subnet created in your VPC"
}

output "private_subnet_2" {
  value       = aws_subnet.databricksubnet_2.id
  description = "Id of the private subnet created in your VPC"
}


output "security_group_id" {
  description = "Security group apply to your EC2 cluster"
  value       = aws_security_group.databricks-control-plane.id
}

output "scc_endpoint" {
  description = "Create Secure cluster connectivity relay endpoint"
  value       = aws_vpc_endpoint.databricks-eu-central-1-workspace-vpce-scc.id
}

output "rest_api_endpoint" {
  description = "Create REST API endpoint"
  value       = aws_vpc_endpoint.databricks-eu-central-1-workspace-vpce-rest.id
}