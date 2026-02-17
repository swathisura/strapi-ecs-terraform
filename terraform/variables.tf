variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ecs_cluster_name" {
  default = "strapi-cluster"
}

variable "ecs_service_name" {
  default = "strapi-service"
}

variable "ecs_task_family" {
  default = "strapi-task"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "desired_count" {
  default = 1
}

variable "ecr_repo_name" {
  default = "strapi-app"
}

variable "docker_image_tag" {
  default = "latest"
}
