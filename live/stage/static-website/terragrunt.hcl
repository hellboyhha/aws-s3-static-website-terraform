terraform {
  source = "../../../modules//s3-static-website/v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {

  region = "<your aws region>"
  static-website-name = "<your static website name>"

}
