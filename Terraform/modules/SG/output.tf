output "security_group_ids" {
  value = {
    for sg_key, sg in aws_security_group.custom : sg_key => sg.id
  }
}