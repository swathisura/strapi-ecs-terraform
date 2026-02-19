variable "aws_region" {
  default = "us-east-1"
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

variable "desired_count" {
  default = 1
}

variable "docker_image_tag" {
  default = "latest"
}

