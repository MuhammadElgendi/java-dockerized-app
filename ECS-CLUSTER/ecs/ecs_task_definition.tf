resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_additional_policy" {
  name = "ecsTaskExecutionAdditionalPolicy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

# resource "aws_ecs_task_definition" "my_task" {
#   family                   = "my-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "512"
#   memory                   = "1024"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn


#   container_definitions = jsonencode([
#     {
#       name      = "my-app"
#       image     = "${var.repository_url}:latest"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 5000
#           hostPort      = 5000
#         }
#       ],
#       environment = [
#         {
#           name  = "MONGO_URL"
#           value = "mongodb://mongo:27017/mydatabase"
#         }
#       ]
#     },
#     {
#       name      = "mongo"
#       image     = "mongo:latest"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 27017
#           hostPort      = 27017
#         }
#       ]
#     }
#   ])
# }
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/my-task"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "my-app"
      image     = "${var.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
      environment = [
        {
          name  = "MONGO_URL"
          value = "mongodb://mongo:27017"
        }
      ],
      dependsOn = [
        {
          containerName = "mongo"
          condition     = "START"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "my-app"
        }
      }
    },
    {
      name      = "mongo"
      image     = "mongo:latest"
      essential = true
      portMappings = [
        {
          containerPort = 27017
          hostPort      = 27017
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "mongo-data"
          containerPath = "/data/db"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "mongo"
        }
      }
      

    }
  ])

  volume {
    name = "mongo-data"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.mongo.id

      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.mongo.id
      }
    }
  }
}

resource "aws_efs_file_system" "mongo" {
  creation_token = "mongo-data"
}

resource "aws_efs_access_point" "mongo" {
  file_system_id = aws_efs_file_system.mongo.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}



resource "aws_ecs_service" "dev_service" {
  name            = "dev-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [var.security_group_id]
  }
  depends_on = [
    aws_iam_role.ecs_task_execution_role,
    aws_efs_file_system.mongo,
    aws_efs_access_point.mongo
  ]
}

resource "aws_ecs_service" "test_service" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [var.security_group_id]
  }
  depends_on = [
    aws_iam_role.ecs_task_execution_role,
    aws_efs_file_system.mongo,
    aws_efs_access_point.mongo
  ]
}
#################
resource "aws_ecs_service" "staging_service" {
  name            = "staging-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [var.security_group_id]
  }
  depends_on = [
    aws_iam_role.ecs_task_execution_role,
    aws_efs_file_system.mongo,
    aws_efs_access_point.mongo
  ]
}
