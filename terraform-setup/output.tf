

output "url" {
  value = "${var.rancher_url}.${data.aws_route53_zone.rancher.name}"
}
output "rancher_cluster_ips" {
  value = [
    aws_instance.rancher.0.public_ip,
    aws_instance.rancher.1.public_ip,
  ]
}

output "downstream_ips" {
	value = aws_instance.downstreams.*.public_ip
}

output "downstream_count" {
	value = var.downstream_count
}

output "rds_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}

output "sql_user" {
  value = "${aws_db_instance.default.username}"
}

output "dbname" {
  value = "${aws_db_instance.default.db_name}"
}
