
module "bastionSG" {
  source = "./modules/SG"
  security_groups = {
    "bastion" = {
      description = "Allow HTTP/S inbound"
      vpc_id      = module.vpc.vpc_id
      name        = "bastion-sg"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
  tags = {
    Name = "bastion-sg"
  }
}
module "SecurityGroup" {
  source = "./modules/SG"
  security_groups = {
    
    "web" = {
      description = "Allow HTTP/S inbound"
      vpc_id      = module.vpc.vpc_id
      name        = "web-sg"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          source_security_group_id = module.bastionSG.security_group_ids["bastion"]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      tags = {
        Name = "web-sg"
      }
    },
    "app" = {
      description = "Allow HTTP/S inbound"
      vpc_id      = module.vpc.vpc_id
      name        = "app-sg"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port                = 22
          to_port                  = 22
          protocol                 = "tcp"
          cidr_blocks              = []
          source_security_group_id = module.bastionSG.security_group_ids["bastion"]
        },
        {
          from_port   = 3601
          to_port     = 3601
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
    "alb" = {
      description = "Allow HTTP/S inbound"
      vpc_id      = module.vpc.vpc_id
      name        = "alb-sg"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
  tags = {
    Name = "general-sg"
  }
}

