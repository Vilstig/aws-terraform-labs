resource "aws_sns_topic" "placki_notifications" {
  name = "${var.name_prefix}-placki-notifications"

  tags = {
    Name = "${var.name_prefix}-placki-notifications"
  }
}

resource "aws_sns_topic_subscription" "placki_email" {
  topic_arn = aws_sns_topic.placki_notifications.arn
  protocol  = "email"
  endpoint  = var.lambda_notification_email
}