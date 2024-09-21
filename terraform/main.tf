provider "aws" {
  region = "eu-north-1"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region eu-north-1 --name ${module.eks.cluster_name}"
  }
  depends_on = [module.eks]
}
