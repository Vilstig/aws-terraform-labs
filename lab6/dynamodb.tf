resource "aws_dynamodb_table" "chat_history" {
  name                        = "${var.name_prefix}-chat-history"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "chatId"
  range_key                   = "timestamp"

  attribute {
    name = "chatId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.name_prefix}-chat-history"
  }
}
