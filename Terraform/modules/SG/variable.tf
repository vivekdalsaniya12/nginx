variable "security_groups" {
  description = "Map of security groups and their ingress/egress rules"
  type = map(object({
    name        = string
    description = string
    vpc_id      = string

    ingress_rules = optional(list(object({
      from_port                = number
      to_port                  = number
      protocol                 = string
      cidr_blocks              = optional(list(string))
      ipv6_cidr_blocks         = optional(list(string))
      prefix_list_ids          = optional(list(string))
      source_security_group_id = optional(string)
      self                     = optional(bool)
      description              = optional(string)
    })), [])

    egress_rules = optional(list(object({
      from_port                = number
      to_port                  = number
      protocol                 = string
      cidr_blocks              = optional(list(string))
      ipv6_cidr_blocks         = optional(list(string))
      prefix_list_ids          = optional(list(string))
      source_security_group_id = optional(string)
      self                     = optional(bool)
      description              = optional(string)
    })), [])
  }))
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}


# variable "security_groups" {
#   description = "Map of security groups to create with their ingress and egress rules"

#   type = map(object({
#     description   = string
#     vpc_id       = string
#     name        = string
#     ingress_rules = list(object({
#       from_port   = number
#       to_port     = number
#       protocol    = string
#       cidr_blocks = list(string)
#       source_security_group_id = optional(string)
#     }))
#     egress_rules = list(object({
#       from_port   = number
#       to_port     = number
#       protocol    = string
#       cidr_blocks = list(string)
#       source_security_group_id = optional(string)
#     }))
#   }))
#   default = {}
# }



# variable "tags" {
#   type    = map(string)
#   default = {}
# }
