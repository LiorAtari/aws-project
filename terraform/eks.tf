module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = "lioratari-eks-cluster"
  cluster_version                = "1.30"  # Specify your desired EKS version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
        most_recent = true
    }
    kube-proxy = {
        most_recent = true
    }
    vpc-cni = {
        most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    instance_types = ["t3.large"]
}

  eks_managed_node_groups = {
    node-group-1 = {
        min_size = 1
        max_size = 1
        desired_size = 1
        instance_types = ["t3.large"]
        capacity_type = "SPOT"
    }
  }
  enable_cluster_creator_admin_permissions = true
}
