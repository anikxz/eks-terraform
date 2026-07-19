# eks-terraform

Terraform configuration for an AWS EKS cluster with a VPC, managed node group, and the
AWS Load Balancer Controller (for provisioning ALBs/NLBs from Kubernetes Ingress/Services).

## What this creates

- **VPC** (`10.0.0.0/16`) with DNS support/hostnames enabled
- **Two public subnets** across `us-west-2a` / `us-west-2b`, tagged for EKS ELB discovery
- **Internet Gateway** + public route table and associations
- **EKS cluster** (`terraform-aws-modules/eks/aws`, `~> 20.0`) with an EKS-managed node group
- **AWS Load Balancer Controller** installed via Helm, using an IRSA role
- **S3 full-access** IAM policy attached to the node group role

## Prerequisites

- Terraform >= 1.3
- AWS credentials/profile with permissions to create the resources above
- The machine running Terraform must be able to reach the EKS Kubernetes API endpoint
  (required so the `helm`/`kubernetes` providers can install the controller)

## Usage

1. Create your `variables.tfvars` by copying the provided example, then edit the values:

   ```bash
   cp variables.tfvars.example variables.tfvars
   ```

   ```hcl
   region                      = "us-west-2"
   profile                     = "default"
   cluster_name                = "my-eks-cluster"
   cluster_version             = "1.29"
   node_group_name             = "my-node-group"
   node_group_desired_capacity = 2
   node_group_max_capacity     = 3
   node_group_min_capacity     = 1
   instance_type               = "t3.medium"
   subnet_cidr_a               = "10.0.1.0/24"
   subnet_cidr_b               = "10.0.2.0/24"
   ```

   > `variables.tfvars` is git-ignored (it may hold environment-specific values).
   > Only `variables.tfvars.example` is committed.

2. Initialize and validate:

   ```bash
   terraform init
   terraform validate
   ```

3. Apply:

   ```bash
   terraform apply -var-file=variables.tfvars
   ```

   > If provider initialization fails because the cluster doesn't exist yet on the first run,
   > apply the cluster first, then apply everything:
   >
   > ```bash
   > terraform apply -target=module.eks -var-file=variables.tfvars
   > terraform apply -var-file=variables.tfvars
   > ```

## Exposing workloads

There is no standalone load balancer resource. Instead, the AWS Load Balancer Controller
provisions load balancers from Kubernetes objects. For example, an ALB via Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app
                port:
                  number: 80
```

The public subnets are tagged with `kubernetes.io/role/elb = 1`, so the controller can
discover them automatically.

## Notes

- `*.tfvars` files are git-ignored (they may contain sensitive values).
- The node group role is granted `AmazonS3FullAccess`. Consider scoping this down (e.g. IRSA
  with a bucket-specific policy) for production use.
- Worker nodes run in public subnets. For production, move them to private subnets behind a
  NAT gateway and keep only load balancers public.
