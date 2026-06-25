data "aws_caller_identity" "current" {}

locals {
  account_id             = data.aws_caller_identity.current.account_id
  ecs_execution_role_arn = "arn:aws:iam::${local.account_id}:role/LabRole"
  ecs_task_role_arn      = "arn:aws:iam::${local.account_id}:role/LabRole"
  lambda_role_arn        = "arn:aws:iam::${local.account_id}:role/LabRole"
  s3_bucket_name         = "${var.name_prefix}-${local.account_id}-chat-images"
}
