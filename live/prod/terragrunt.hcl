terragrunt_version_constraint = ">= v0.36.0"

generate "provider" {

  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "<your aws region>"
}
EOF

}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "<your aws s3 bucket name>"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "<your aws region>"
    encrypt        = true
    dynamodb_table = "<your aws dynamodb table name>"
  }
}
