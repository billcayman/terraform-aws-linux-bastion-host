output "default_vpc" {
  value = data.aws_vpc.default_vpc.id
  description = "Default VPC id is : "
}

output "default_subnets" {
  value = data.aws_subnet_ids.default_subnets.ids
  description = "Default Subnet IDs : "
}

output "az_list" {
  value = data.aws_availability_zones.azs.names
}

output "lb_dns" {
  value = aws_lb.my_nlb.dns_name
}
/*
output "asg_data" {
  value = aws_autoscaling_group.bar
  description = "ASG data"
}

output "launch_template" {
  value = aws_launch_template.my_launch_template
}
*/