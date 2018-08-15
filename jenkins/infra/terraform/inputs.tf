
variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "mdn"
}

variable "domain" {
  default = "mdn.mozit.cloud"
}

variable "ssh_pubkey" {
	default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClyrknFMLehaBAAAU8L3xTHfY03E8yB7sJ4NmnJgqAjn7yShdW1JCjE69FzWVnFtEUF6GRFCDyOPPQeH7RJZkFKMgB2VqDTi6Cz2k4ltzYLbQulbLd9tc+NYQwY/y/ijCFFawUWn8b6rJaIPNf5qHhEih3RDqYRc6RiZIW2nvwWZQjD3XUMnMWeri5wm+XZpOb69cIVXlB5yNzqBzeOAf5+zXYWaXW6PqPXfNEZWOy+NQLld0WVgxRZsU8WBGBL96l0YwmIaBVTcIATsTlwqdR7Jc1p2/lT5g3aDghCu0dSgJ7rhVhCnuK08jmy40g+K88N09sQJzTn1WzLzPewU3bU9LeyYU88PDlw6f+2FAKBeLLea498/eS6/mat0A93JmKvpSe4FfYR7BM8W4qNUKVFacOkJTYkEOJuFSK/mb2xl9JtuEdjAQw70s2I+4QXSGxowjA8NCegDK/a+00GbsT2M8JKV1LmH64Itx3uux2LW76hatNFAzohbCdRu3p/7B+QUn8dmTCRKJVC+hfpyKU2O1eAtknJww0LdWa/3crgkLIdA/hxWkAgE1csPXmLwWu7uPO6QcvzWK5oXBb/zgZJ8PmJtl/hDpuae3wBv9BJ7Eq6Eznp784Lan3aMHJs2XqKJTpUQ5RkZdSog4SUj8Wjxw5WLevJXPYrxyX1XfFqw== mdn"
}

variable "backup_bucket" {
  default = "ci-backup"
}

