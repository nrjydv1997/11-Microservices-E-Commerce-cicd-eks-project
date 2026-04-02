variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "project-node-group"
}

variable "key_name" {
  description = "EC2 keypair"
  type = string
  default = "Devops-Key"
}