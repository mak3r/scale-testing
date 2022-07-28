

output "rancher_domain" {
  value = data.aws_route53_zone.rancher.name
}
output "rancher_cluster_ips" {
  value = [
    aws_instance.vms.0.public_ip,
    aws_instance.vms.1.public_ip,
  ]
}

output "rds_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}
