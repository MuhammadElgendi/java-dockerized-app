# resource "aws_ecs_service" "dev_service" {
#   name            = "dev-service"
#   cluster         = aws_ecs_cluster.my_cluster.id
#   task_definition = aws_ecs_task_definition.my_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets         = var.subnets
#     security_groups = [var.security_group_id]
#   }
#   depends_on = [
#     aws_iam_role.ecs_task_execution_role,
#     aws_efs_file_system.mongo,
#     aws_efs_access_point.mongo
#   ]
# }

# resource "aws_ecs_service" "test_service" {
#   name            = "test-service"
#   cluster         = aws_ecs_cluster.my_cluster.id
#   task_definition = aws_ecs_task_definition.my_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets         = var.subnets
#     security_groups = [var.security_group_id]
#   }
#   depends_on = [
#     aws_iam_role.ecs_task_execution_role,
#     aws_efs_file_system.mongo,
#     aws_efs_access_point.mongo
#   ]
# }

# resource "aws_ecs_service" "staging_service" {
#   name            = "staging-service"
#   cluster         = aws_ecs_cluster.my_cluster.id
#   task_definition = aws_ecs_task_definition.my_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets         = var.subnets
#     security_groups = [var.security_group_id]
#   }
#   depends_on = [
#     aws_iam_role.ecs_task_execution_role,
#     aws_efs_file_system.mongo,
#     aws_efs_access_point.mongo
#   ]
# }
