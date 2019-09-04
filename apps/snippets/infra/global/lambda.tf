
# Lambda@edge to set origin response headers
resource "aws_iam_role" "lambda-edge-role" {
  name = "snippets-lambda-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
       ]
     },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "stage-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/stage-lambda.zip"
}

provider "aws" {
  alias  = "aws-lambda-east"
  region = "us-east-1"
}

resource "aws_lambda_function" "stage-lambda" {
  provider         = "aws.aws-lambda-east"
  function_name    = "snippets-stage-resp"
  description      = ""
  publish          = "true"
  filename         = "${path.module}/stage-lambda.zip"
  source_code_hash = "${data.archive_file.stage-lambda-zip.output_base64sha256}"
  role             = "${aws_iam_role.lambda-edge-role.arn}"
  handler          = "lambda.lambda_handler"
  runtime          = "python3.7"

  tags {
    Name        = "snippets-stage-headers"
    ServiceName = "snippets stage"
    Terraform   = "true"
  }
}
