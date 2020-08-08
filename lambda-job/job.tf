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


/* I've taken the following from
 * https://github.com/hashicorp/terraform/issues/4393#issuecomment-194287540
 */


resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}


resource "aws_cloudwatch_event_target" "check_every_five_minutes" {
    rule = aws_cloudwatch_event_rule.every_five_minutes.name
    target_id = "check_foo"
    arn = aws_lambda_function.vulns-lambda-job.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_check" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.vulns-lambda-job.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_five_minutes.arn
}
