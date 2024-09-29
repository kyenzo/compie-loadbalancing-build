variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "my-key-pair" # Replace with your actual key pair name
}

variable "admin_phone_number" {
  description = "Admin phone number for SNS notifications (E.164 format)"
  type        = string
  default     = "+11234567890" # Replace with your admin's phone number
}

variable "secrets_manager_account_id" {
  description = "AWS Account ID to grant read-only access to the secrets"
  type        = string
  default     = "123456789012" # Replace with the AWS Account ID
}

variable "enable_on_prem_connection" {
  description = "Enable on-premises server connection to DynamoDB"
  type        = bool
  default     = false
}

variable "on_prem_ip" {
  description = "The IP address of the on-premises server"
  type        = string
  default     = "" # Set to your on-premises server IP if applicable
}
