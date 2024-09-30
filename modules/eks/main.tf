resource "aws_security_group" "security-group" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.prefix}-security-group"
  }
  egress {
    from_port       = 0             // all
    to_port         = 0             // all
    protocol        = "-1"          // all
    cidr_blocks     = ["0.0.0.0/0"] // all
    prefix_list_ids = []
  }
}

resource "aws_iam_role" "cluster-role" {
  name               = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/eks/${var.cluster_name}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
}

resource "aws_eks_cluster" "cluster" {
  name                      = "${var.prefix}-${var.cluster_name}"
  role_arn                  = aws_iam_role.cluster-role.arn
  enabled_cluster_log_types = ["api", "audit"]
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.security-group.id]
  }
  depends_on = [aws_cloudwatch_log_group.logs,
  aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy, aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController]
}

resource "aws_iam_role" "node" {
  name               = "${var.prefix}-${var.cluster_name}-node"
  assume_role_policy = <<POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
                }
            ]
        }
        POLICY
}


resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
} // permite que os pods se comuniquem entre si

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
} // permite que os pods se comuniquem com o ECR


resource "aws_eks_node_group" "node-2" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.prefix}-node-group-2"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.micro"] // micro para nao ter cobrancas
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

}

