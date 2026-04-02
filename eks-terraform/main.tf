provider "aws" {
  region = "ap-south-1"
}

########################################
# IAM ROLE FOR EKS CLUSTER
########################################

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

########################################
# IAM ROLE FOR WORKER NODES
########################################

resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  role       = aws_iam_role.eks_worker_role.name
  policy_arn = each.value
}

########################################
# VPC DATA SOURCES
########################################

data "aws_vpc" "main" {
  tags = { Name = "Jumphost-vpc" }
}

data "aws_subnet" "private_1" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["private-subnet1"]
  }
}

data "aws_subnet" "private_2" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["private-subnet2"]
  }
}

data "aws_security_group" "bastion_sg" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["jump-server-sg"]
  }
}

########################################
# SECURITY GROUPS
########################################

# Worker SG
resource "aws_security_group" "eks_worker_sg" {
  name   = "eks-worker-sg"
  vpc_id = data.aws_vpc.main.id
}

# Cluster SG
resource "aws_security_group" "eks_cluster_sg" {
  name   = "eks-cluster-sg"
  vpc_id = data.aws_vpc.main.id
}

# Worker → Cluster (443)
resource "aws_security_group_rule" "cluster_ingress_from_worker" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_worker_sg.id
}

# Bastion → Cluster (kubectl access)
resource "aws_security_group_rule" "cluster_ingress_from_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = data.aws_security_group.bastion_sg.id
}

# Worker internal communication
resource "aws_security_group_rule" "worker_node_to_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_worker_sg.id
}

# Worker outbound
resource "aws_security_group_rule" "worker_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_worker_sg.id
}

########################################
# EKS CLUSTER
########################################

resource "aws_eks_cluster" "eks" {
  name     = "project-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = [data.aws_subnet.private_1.id, data.aws_subnet.private_2.id]
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policies]
}

########################################
# EKS NODE GROUP
########################################

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [data.aws_subnet.private_1.id, data.aws_subnet.private_2.id]

  instance_types = ["c7i-flex.large"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [aws_iam_role_policy_attachment.eks_worker_policies]
}

########################################
# OIDC PROVIDER (IRSA)
########################################

data "aws_eks_cluster" "oidc" {
  name = aws_eks_cluster.eks.name
}

data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.oidc.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.oidc.identity[0].oidc[0].issuer
}