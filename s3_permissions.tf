resource "aws_iam_role_policy_attachment" "eks_s3_full_permission" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = module.eks.eks_managed_node_groups[var.node_group_name].iam_role_name
}
