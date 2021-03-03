terraform {
  backend "remote" {
    organization = "ManiakVenturesInc"

    workspaces {
      name = "learning-vault-aws"
    }
  }
}