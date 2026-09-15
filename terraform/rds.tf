# ------------------------------------------------------------------
# RDS - PostgreSQL
# Sits in the private subnets, only the app SG can reach it on 5432.
# ------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "random_id" "db_suffix" {
  byte_length = 3
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-postgres-${random_id.db_suffix.hex}"
  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_days
  backup_window           = "03:00-04:00" # low traffic hours, IST early morning-ish
  maintenance_window      = "sun:04:30-sun:05:30"

  deletion_protection = var.db_deletion_protection
  skip_final_snapshot  = !var.db_deletion_protection
  final_snapshot_identifier = var.db_deletion_protection ? "${var.project_name}-final-snapshot" : null

  # not going for performance insights / enhanced monitoring by default
  # to keep this cheap - flip these on for real prod workloads
  performance_insights_enabled = false

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
