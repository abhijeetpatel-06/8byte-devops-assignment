output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB + NAT live here)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (app + RDS live here)"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "Point your domain's CNAME at this to reach the app"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "Needed if you're setting up a Route53 alias record instead of a CNAME"
  value       = aws_lb.app.zone_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group running the app"
  value       = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  description = "Postgres connection endpoint (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "Just the hostname part, useful for app config"
  value       = aws_db_instance.postgres.address
}

output "rds_database_name" {
  value = aws_db_instance.postgres.db_name
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
