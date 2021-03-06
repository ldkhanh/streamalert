resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "InvokeFromS3Bucket${title(replace(var.bucket_id, ".", ""))}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_id}"
  qualifier     = "production"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  # Note: With cross-account notifications, this would not succeed since the bucket
  #       would not be owned in the same account as the Lambda function.
  count = "${var.enable_events ? 1 : 0}"

  bucket = "${var.bucket_id}"

  lambda_function {
    lambda_function_arn = "${var.lambda_function_arn}:production"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_iam_role_policy" "lambda_s3_permission" {
  name = "InvokeFromS3Bucket${title(replace(var.bucket_id, ".", ""))}"
  role = "${var.lambda_role_id}"

  policy = "${data.aws_iam_policy_document.s3_read_only.json}"
}

// IAM Policy Doc: S3 Get Object
data "aws_iam_policy_document" "s3_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_id}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_id}/*",
    ]
  }
}
