resource "helm_release" "arogcd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "4.9.8"
  namespace = "argocd"
  create_namespace = true
  values = [
    file("values/argocd-values.yaml")
  ]
  depends_on = [module.eks]
}
