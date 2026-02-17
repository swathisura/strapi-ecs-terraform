output "ecs_cluster_name" {
  value = aws_ecs_cluster.strapi_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.strapi_service.name
}

output "ecr_repo_url" {
  value = aws_ecr_repository.strapi_repo.repository_url
}
