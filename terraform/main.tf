provider "aws" {
  region = var.aws_region
}

# ===============================
# DEFAULT VPC + SUBNETS (SAFE)
# ===============================
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ===============================
# SECURITY GROUP
# ===============================
resource "aws_security_group" "strapi_sg" {
  name   = "strapi-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ===============================
# ECS CLUSTER
# ===============================
resource "aws_ecs_cluster" "strapi_cluster" {
  name = var.ecs_cluster_name
}

# ===============================
# EXISTING IAM ROLE (DO NOT CREATE)
# ===============================
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
}

# ===============================
# EXISTING ECR REPO
# ===============================
data "aws_ecr_repository" "strapi_repo" {
  name = var.ecr_repo_name
}

# ===============================
# ECS TASK DEFINITION
# ===============================
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi-app"
      image     = "${data.aws_ecr_repository.strapi_repo.repository_url}:${var.docker_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ===============================
# ECS SERVICE (FARGATE)
# ===============================
resource "aws_ecs_service" "strapi_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_cluster.strapi_cluster]
}

