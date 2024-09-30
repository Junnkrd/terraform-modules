locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority[0].data}
    server: ${aws_eks_cluster.cluster.endpoint}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: "${aws_eks_cluster.cluster.name}"
  name: "${aws_eks_cluster.cluster.name}"
current-context: "${aws_eks_cluster.cluster.name}"
kind: Config
preferences: {}
users:
- name: "${aws_eks_cluster.cluster.name}"
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - get-token
      - -i
      - ${aws_eks_cluster.cluster.name}
      command: aws
KUBECONFIG
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig"
  content  = local.kubeconfig
}
