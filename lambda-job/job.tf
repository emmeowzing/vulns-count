provider "aws" {
  region = "us-east-1"
}


resource "aws_lambda_function" "vulns-lambda-job" {
  # I manually created the following role, so I will specify its ARN here instead of creating a new one.
  role = "arn:aws:iam::317200895319:role/vulns-lambda-job"

  function_name = "publish-vulns"
  description = "A function that periodically publishes vulnerability counts to Datadog."
  timeout = 60

  handler = "get-vulns.entrypoint"
  runtime = "python3.8"

  # The following is ignored by git, to be built from the script build-update.sh.
  filename = "src/package.zip"
  source_code_hash = filebase64sha256("src/package.zip")

  memory_size = 128

  tags = {
    Name = "publish-vulns"
    Owner = "Brandon"
  }
}