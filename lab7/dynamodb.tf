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

resource "aws_dynamodb_table" "live_chat" {
  name         = "${var.name_prefix}-live-chat"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "roomId"
  range_key    = "sortKey"

  attribute {
    name = "roomId"
    type = "S"
  }

  attribute {
    name = "sortKey"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "${var.name_prefix}-live-chat"
  }
}

resource "aws_dynamodb_table" "messages" {
  name         = "${var.name_prefix}-messages"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "messageId"

  attribute {
    name = "messageId"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "${var.name_prefix}-messages"
  }
}