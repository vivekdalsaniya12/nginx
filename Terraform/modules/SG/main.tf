resource "aws_security_group" "custom" {
  for_each = var.security_groups

  name        = "${each.value.name}-${each.key}"
  description = each.value.description
  vpc_id      = each.value.vpc_id

  tags = merge(var.tags, {
    Name = "${each.value.name}"
  })
}

locals {
  ingress_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for idx, rule in lookup(sg, "ingress_rules", []) : {
        id      = "${sg_name}-ingress-${idx}"
        sg_name = sg_name
        rule    = rule
      }
    ]
  ])

  egress_rules = flatten([
    for sg_name, sg in var.security_groups : [
      for idx, rule in lookup(sg, "egress_rules", []) : {
        id      = "${sg_name}-egress-${idx}"
        sg_name = sg_name
        rule    = rule
      }
    ]
  ])
}

resource "aws_security_group_rule" "ingress" {
  for_each = {
    for r in local.ingress_rules : r.id => r
  }

  type                     = "ingress"
  from_port                = each.value.rule.from_port
  to_port                  = each.value.rule.to_port
  protocol                 = each.value.rule.protocol
  cidr_blocks              = lookup(each.value.rule, "cidr_blocks", [])
  ipv6_cidr_blocks         = lookup(each.value.rule, "ipv6_cidr_blocks", [])
  prefix_list_ids          = lookup(each.value.rule, "prefix_list_ids", [])
  source_security_group_id = lookup(each.value.rule, "source_security_group_id", null)
  self                     = lookup(each.value.rule, "self", null)
  description              = lookup(each.value.rule, "description", null)
  security_group_id        = aws_security_group.custom[each.value.sg_name].id
}

resource "aws_security_group_rule" "egress" {
  for_each = {
    for r in local.egress_rules : r.id => r
  }

  type                     = "egress"
  from_port                = each.value.rule.from_port
  to_port                  = each.value.rule.to_port
  protocol                 = each.value.rule.protocol
  cidr_blocks              = lookup(each.value.rule, "cidr_blocks", [])
  ipv6_cidr_blocks         = lookup(each.value.rule, "ipv6_cidr_blocks", [])
  prefix_list_ids          = lookup(each.value.rule, "prefix_list_ids", [])
  source_security_group_id = lookup(each.value.rule, "source_security_group_id", null)
  self                     = lookup(each.value.rule, "self", null)
  description              = lookup(each.value.rule, "description", null)
  security_group_id        = aws_security_group.custom[each.value.sg_name].id
}

# Optional default egress if none specified
resource "aws_security_group_rule" "default_egress" {
  for_each = {
    for sg_name, sg in var.security_groups : sg_name => sg
    if !contains(keys(sg), "egress_rules") || length(sg.egress_rules) == 0
  }

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Default allow all egress"
  security_group_id = aws_security_group.custom[each.key].id
}



# resource "aws_security_group" "custom" {
#   for_each = var.security_groups
#   name        = "${each.value.name}-${each.key}"
#   description = each.value.description
#   vpc_id      = each.value.vpc_id
#   tags = merge(var.tags, {
#     Name = "${each.value.name}"
#   })
# }


# locals {
#   ingress_rules = flatten([
#     for sg_name, sg in var.security_groups : [
#       for idx, rule in sg.ingress_rules : {
#         id      = "${sg_name}-ingress-${idx}"
#         sg_name = sg_name
#         rule    = rule
#       }
#     ]
#   ])

#   egress_rules = flatten([
#     for sg_name, sg in var.security_groups : [
#       for idx, rule in sg.egress_rules : {
#         id      = "${sg_name}-egress-${idx}"
#         sg_name = sg_name
#         rule    = rule
#       }
#     ]
#   ])
# }


# resource "aws_security_group_rule" "ingress" {
#   for_each = {
#     for r in local.ingress_rules : r.id => r
#   }

#   type              = "ingress"
#   from_port         = each.value.rule.from_port
#   to_port           = each.value.rule.to_port
#   protocol          = each.value.rule.protocol
#   cidr_blocks       = lookup(each.value.rule, "cidr_blocks", [])
#   security_group_id = aws_security_group.custom[each.value.sg_name].id
#   source_security_group_id = lookup(each.value.rule, "source_security_group_id", null)
# }

# resource "aws_security_group_rule" "egress" {
#   for_each = {
#     for r in local.egress_rules : r.id => r
#   }

#   type              = "egress"
#   from_port         = each.value.rule.from_port
#   to_port           = each.value.rule.to_port
#   protocol          = each.value.rule.protocol
#   cidr_blocks       = lookup(each.value.rule, "cidr_blocks", [])
#   security_group_id = aws_security_group.custom[each.value.sg_name].id
#   source_security_group_id = lookup(each.value.rule, "source_security_group_id", null)
# }