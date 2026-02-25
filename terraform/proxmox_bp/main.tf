
# module "ci-u2024-basic" {
#   source         = "./modules/ci-u2404-basic"
#   name           = "ci-u2024-basic-instance"
#   memory         = 2048
#   instance_count = 1
# }

module "ci-u2024" {
  source         = "./modules/ci-u2404"
  name           = "ci-u2024-instance"
  memory         = 2048
  instance_count = 1
}
