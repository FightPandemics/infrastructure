resource "aws_security_group" "cache" {
  name        = "fp-${var.fp_context}-cache"
  description = "Allow inbound traffic to fp-${var.fp_context}-cache from VPC only"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "fp-${var.fp_context}-cache"
  }
}
