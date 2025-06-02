
module "ec2" {
  source = "./modules/ec2"

  instances = merge(
    {
      for i in range(2) : "app-server-${i + 1}" => {
        name                        = "app-server-${i + 1}"
        ami                         = "ami-0f5ee92e2d63afc18"
        instance_type               = "t2.micro"
        subnet_id                   = module.vpc.private_subnet_ids["10.0.101.0/24"]
        key_name                    = file("./terra-key.pub")
        associate_public_ip_address = false
        security_group_ids          = [module.SecurityGroup.security_group_ids["app"]]
        root_volume_size            = 8
        root_volume_type            = "gp3"
        root_volume_encrypted       = true
        availability_zone           = "us-west-2a"
        # user_data                   = file("./scripts/app-server.sh")
        # ebs_optimized               = true
        # monitoring                  = true
        # disable_api_termination     = true
        # tenancy                     = "default"
        # private_ip                  = "10.0.101.${i + 10}"
        # iam_instance_profile        = "app-server-profile"
        tags = {
          ENV = "dev"
        }
      }
    },
    {
      for i in range(1) : "web-server-${i + 1}" => {
        name                        = "web-server-${i + 1}"
        ami                         = "ami-0f5ee92e2d63afc18"
        instance_type               = "t2.micro"
        subnet_id                   = module.vpc.public_subnet_ids["10.0.1.0/24"]
        key_name                    = file("./terra-key.pub")
        security_group_ids          = [module.SecurityGroup.security_group_ids["web"]]
        associate_public_ip_address = true
        tags = {
          ENV = "dev"
        }
      }
    }

  )
  tags = {
    project    = "facelog"
    owner      = "vivek_dalsaniya"
    launchDate = "22-may-2025"
  }
}


