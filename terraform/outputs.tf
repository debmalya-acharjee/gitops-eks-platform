output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "next_steps" {
  value = <<-EOT

    1. Configure kubectl:
       aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}

    2. Verify node access:
       kubectl get nodes

    3. Install ArgoCD — see ../argocd/install/README.md

    4. Register the sample app — apply ../argocd/apps/sample-app-application.yaml

  EOT
}
