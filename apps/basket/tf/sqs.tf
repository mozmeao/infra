resource "aws_sqs_queue" "basket_delete_queue_dev" {
  name = "basket_delete_queue_dev"
}

resource "aws_sqs_queue" "basket_delete_queue_stage" {
  name = "basket_delete_queue_stage"
}

resource "aws_sqs_queue" "basket_delete_queue_prod" {
  name = "basket_delete_queue_prod"
}
