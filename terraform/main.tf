provider "aws" {
  region = "eu-north-1"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}