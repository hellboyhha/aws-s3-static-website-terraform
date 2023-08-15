terraform {
  source = "../../../modules//s3-static-website/v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {

  region = "us-east-1"
  static-website-name = "stage-static-website-starshoppin"

}