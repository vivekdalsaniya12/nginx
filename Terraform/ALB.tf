

module "alb" {
  source = "./modules/alb"

  name            = "web-alb"
  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.public_subnet_ids["10.0.1.0/24"], module.vpc.public_subnet_ids["10.0.2.0/24"]]
  security_groups = [module.SecurityGroup.security_group_ids["alb"]]

  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "app-tg"
      }
      rules = [
        {
          priority         = 10
          path_patterns    = ["/app*"]
          target_group_key = "app-tg"
        },
        {
          priority         = 20
          path_patterns    = ["/web*"]
          target_group_key = "web-tg"
        }
      ]
    }


  ]

  target_groups = {
    "app-tg" = {
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      health_check = {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-299"
      }
      targets = [
        for id in data.aws_instances.app.ids : {
          id   = id
          port = 80
        }
      ]
    },
    "web-tg" = {
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      health_check = {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-299"
      }
      targets = [
        for id in data.aws_instances.web.ids : {
          id   = id
          port = 80
        }
      ]
    }
  }

  tags = {
    Environment = "dev"
  }
}
