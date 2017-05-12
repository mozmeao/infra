resource "aws_sqs_queue" "basket_delete_queue_dev" {
  name = "basket_delete_queue_dev"
}

resource "aws_sqs_queue" "basket_delete_queue_stage" {
  name = "basket_delete_queue_stage"
}

resource "aws_sqs_queue" "basket_delete_queue_prod" {
  name = "basket_delete_queue_prod"
}


resource "aws_sqs_queue_policy" "basket_delete_queue_dev_cross_account" {
  queue_url = "${aws_sqs_queue.basket_delete_queue_dev.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::${var.fxa_dev_account}:root"]
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "${aws_sqs_queue.basket_delete_queue_dev.arn}"
    }
  ]
}
POLICY
}


resource "aws_sqs_queue_policy" "basket_delete_queue_stage_cross_account" {
  queue_url = "${aws_sqs_queue.basket_delete_queue_stage.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::${var.fxa_stage_account}:root"]
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "${aws_sqs_queue.basket_delete_queue_stage.arn}"
    }
  ]
}
POLICY
}


resource "aws_sqs_queue_policy" "basket_delete_queue_prod_cross_account" {
  queue_url = "${aws_sqs_queue.basket_delete_queue_prod.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::${var.fxa_prod_account}:root"]
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "${aws_sqs_queue.basket_delete_queue_prod.arn}"
    }
  ]
}
POLICY
}
