module "new-vpc" {
  source         = "./modules/vpc" // tem que ter o ./
  prefix         = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}
# "10.0.0.0/16"
module "eks" {
  source         = "./modules/eks"
  prefix         = var.prefix
  vpc_id         = module.new-vpc.vpc_id
  cluster_name   = var.cluster_name
  retention_days = var.retention_days
  subnet_ids     = module.new-vpc.subnet_ids
  desired_size   = var.desired_size
  max_size       = var.max_size
  min_size       = var.min_size
}


