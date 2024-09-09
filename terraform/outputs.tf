output "bastion_host_connect" {
  value = aws_instance.baston_host.public_ip
}

# output "redis_address" {
#   value = aws_elasticache_cluster.redis.cluster_address
# }
