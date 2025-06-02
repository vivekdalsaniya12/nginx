resource "aws_instance" "this" {
  for_each = { for i, inst in var.instances : i => inst }

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                    = each.value.key_name

  user_data               = lookup(each.value, "user_data", null)
  iam_instance_profile    = lookup(each.value, "iam_instance_profile", null)
  ebs_optimized           = lookup(each.value, "ebs_optimized", false)
  monitoring              = lookup(each.value, "monitoring", false)
  disable_api_termination = lookup(each.value, "disable_api_termination", false)
  private_ip              = lookup(each.value, "private_ip", null)

  root_block_device {
    volume_size           = lookup(each.value, "root_volume_size", 8)
    volume_type           = lookup(each.value, "root_volume_type", "gp3")
    encrypted             = lookup(each.value, "root_volume_encrypted", true)
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  availability_zone = lookup(each.value, "availability_zone", null)
  tenancy           = lookup(each.value, "tenancy", null)

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = "${each.value.name}"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [user_data]
  }
}



# resource "aws_instance" "this" {
#   for_each = { for i, inst in var.instances : i => inst }

#   ami = each.value.ami
#   instance_type = each.value.instance_type
#   subnet_id = each.value.subnet_id
#   vpc_security_group_ids = each.value.security_group_ids
#   associate_public_ip_address = each.value.associate_public_ip_address
#   key_name = each.value.key_name

#   tags = merge(
#     var.tags,
#     each.value.tags,
#     {
#       Name = "${each.value.name}"
#     }
#   )
# }

