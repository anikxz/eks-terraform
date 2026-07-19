module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = aws_vpc.eks_vpc.id
  subnet_ids      = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]

  eks_managed_node_groups = {
    (var.node_group_name) = {
      desired_size   = var.node_group_desired_capacity
      max_size       = var.node_group_max_capacity
      min_size       = var.node_group_min_capacity
      instance_types = [var.instance_type]
    }
  }
}
