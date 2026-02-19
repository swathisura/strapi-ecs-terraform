provider "aws" {
  region = var.aws_region
}

# -------------------------------
# VPC, Subnet, Security Group
# -------------------------------
resource "aws_vpc" "strapi_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "strapi_subnet" {
  vpc_id                  = aws_vpc.strapi_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "strapi_sg" {
  name   = "strapi-sg"
  vpc_id = aws_vpc.strapi_vpc.id

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

# -------------------------------
# ECS Cluster
# -------------------------------
resource "aws_ecs_cluster" "strapi_cluster" {
  name = var.ecs_cluster_name
}

# -------------------------------
# EXISTING IAM ROLE (DATA SOURCE)
# -------------------------------
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
}

# -------------------------------
# EXISTING ECR REPO (DATA SOURCE)
# -------------------------------
data "aws_ecr_repository" "strapi_repo" {
  name = "strapi-app"
}

# -------------------------------
# ECS Task Definition (Fargate)
# -------------------------------
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

# -------------------------------
# ECS Service (Fargate)
# -------------------------------
resource "aws_ecs_service" "strapi_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.strapi_subnet.id]
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }
}

