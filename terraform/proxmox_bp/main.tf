
variable "num_vms" {
  default = 3
}

module "ci-test" {
  count  = var.num_vms
  source = "./modules/ci-test"
  name   = "module-test-${count.index + 1}"
  memory = 1024
}
