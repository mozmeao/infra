output "delete_queue_dev_url" {
  value = "${aws_sqs_queue.basket_delete_queue_dev.id}"
}

output "delete_queue_dev_arn" {
  value = "${aws_sqs_queue.basket_delete_queue_dev.arn}"
}



output "delete_queue_stage_url" {
  value = "${aws_sqs_queue.basket_delete_queue_stage.id}"
}

output "delete_queue_stage_arn" {
  value = "${aws_sqs_queue.basket_delete_queue_stage.arn}"
}



output "delete_queue_prod_url" {
  value = "${aws_sqs_queue.basket_delete_queue_prod.id}"
}

output "delete_queue_prod_arn" {
  value = "${aws_sqs_queue.basket_delete_queue_prod.arn}"
}
