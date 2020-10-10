resource "aws_elasticache_subnet_group" "cache" {
  name       = "fp-${var.fp_context}-cache"
  subnet_ids = data.aws_subnet_ids.private.ids
}
