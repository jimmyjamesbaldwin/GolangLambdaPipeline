resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket}"
  acl    = "private"
}

resource "aws_iam_role" "lambda_role" {
  name = "HelloWorldLambda"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_lambda_function" "function" {
  filename      = "lambda.zip"
  function_name = "HelloWorld"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "main"
  runtime       = "go1.x"
}

resource "aws_lambda_alias" "alias" {
  name             = "production"
  description      = ""
  function_name    = "${aws_lambda_function.function.arn}"
  function_version = "$LATEST"
}
