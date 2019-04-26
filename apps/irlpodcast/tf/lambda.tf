
# Lambda@edge to set origin response headers
resource "aws_iam_role" "lambda-edge-role" {
  name = "irlpodcast-lambda-exec-role"

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

// Stage and prod are pointing at the same javascript file.
// Change this if we want to deploy stage separately for 
// development.
data "archive_file" "prod-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-headers.js"
  output_path = "${path.module}/prod-lambda-headers.zip"
}

data "archive_file" "stage-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-headers.js"
  output_path = "${path.module}/stage-lambda-headers.zip"
}

data "archive_file" "www-prod-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/www-lambda.js"
  output_path = "${path.module}/www-lambda.zip"
}


provider "aws" {
  alias  = "aws-lambda-east"
  region = "us-east-1"
}

resource "aws_lambda_function" "stage-lambda-headers" {
  provider         = "aws.aws-lambda-east"
  function_name    = "irlpodcast-stage-resp-headers"
  description      = "Provides correct response Headers for irlpodcast stage"
  publish          = "true"
  filename         = "${path.module}/stage-lambda-headers.zip"
  source_code_hash = "${data.archive_file.stage-lambda-zip.output_base64sha256}"
  role             = "${aws_iam_role.lambda-edge-role.arn}"
  handler          = "lambda-headers.handler"
  runtime          = "nodejs8.10"

  tags {
    Name        = "irlpodcast-stage-headers"
    ServiceName = "irlpodcast stage"
    Terraform   = "true"
  }
}


resource "aws_lambda_function" "prod-lambda-headers" {
  provider         = "aws.aws-lambda-east"
  function_name    = "irlpodcast-prod-resp-headers"
  description      = "Provides correct response Headers for irlpodcast prod"
  publish          = "true"
  filename         = "${path.module}/prod-lambda-headers.zip"
  source_code_hash = "${data.archive_file.prod-lambda-zip.output_base64sha256}"
  role             = "${aws_iam_role.lambda-edge-role.arn}"
  handler          = "lambda-headers.handler"
  runtime          = "nodejs8.10"

  tags {
    Name        = "irlpodcast-prod-headers"
    ServiceName = "irlpodcast prod"
    Terraform   = "true"
  }
}

resource "aws_lambda_function" "www-prod-lambda" {
  provider         = "aws.aws-lambda-east"
  function_name    = "irlpodcast-prod-www"
  description      = "Redirect www.irlpodcast.org requests to webpodcast.org"
  publish          = "true"
  filename         = "${path.module}/www-lambda.zip"
  source_code_hash = "${data.archive_file.www-prod-lambda-zip.output_base64sha256}"
  role             = "${aws_iam_role.lambda-edge-role.arn}"
  handler          = "www-lambda.handler"
  runtime          = "nodejs8.10"

  tags {
    Name        = "irlpodcast-www"
    ServiceName = "irlpodcast www"
    Terraform   = "true"
  }
}