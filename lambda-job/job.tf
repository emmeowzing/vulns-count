module "lambda" {
  source  = "terraform-module/lambda/aws"
  version = "2.7.0"

  function_name = "plot-vulns"
  filename = ""
}