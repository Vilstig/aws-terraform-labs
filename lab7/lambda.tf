data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/message_processor"
  output_path = "${path.module}/lambda/message_processor.zip"
}

resource "aws_cloudwatch_log_group" "lambda_message_processor" {
  name              = "/aws/lambda/${var.name_prefix}-message-processor"
  retention_in_days = 1
}

resource "aws_lambda_function" "message_processor" {
  function_name    = "${var.name_prefix}-message-processor"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "python3.12"
  role             = local.lambda_role_arn
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      MESSAGES_TABLE_NAME = aws_dynamodb_table.messages.name
      SNS_TOPIC_ARN       = aws_sns_topic.placki_notifications.arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_message_processor,
    aws_dynamodb_table.messages,
    aws_sns_topic.placki_notifications,
  ]

  tags = {
    Name = "${var.name_prefix}-message-processor"
  }
}
