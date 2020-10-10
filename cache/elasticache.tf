locals {
  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
}

resource "aws_elasticache_replication_group" "cache" {
  replication_group_id          = "fp-${var.fp_context}-cache"
  automatic_failover_enabled    = var.fp_context == "production"
  availability_zones            = var.fp_context == "production" ? local.azs : [local.azs[0]]
  replication_group_description = "Replication group for fp-${var.fp_context}-cache"
  node_type                     = "cache.t3.micro"
  number_cache_clusters         = var.fp_context == "production" ? 2 : 1
  parameter_group_name          = "default.redis5.0"
  engine_version                = "5.0.6"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.cache.name
  security_group_ids            = [aws_security_group.cache.id]

  tags = {
    Name = "fp-${var.fp_context}-cache"
  }
}
