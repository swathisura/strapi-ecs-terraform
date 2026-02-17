output "ecs_cluster_name" {
  value = aws_ecs_cluster.strapi_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.strapi_service.name
}

output "ecr_repo_url" {
  value = 976136922849.dkr.ecr.us-east-1.amazonaws.com/strapi-app
}
