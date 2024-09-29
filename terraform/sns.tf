# SNS Topic for Notifications
resource "aws_sns_topic" "scale_topic" {
  name = "scale-notifications"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.scale_topic.arn
  protocol  = "sms"
  endpoint  = var.admin_phone_number
}
