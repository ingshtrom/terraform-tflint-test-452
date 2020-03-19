terraform {
  required_providers {
    aws = "= 2.51.0"
    random = "= 2.2.1"
  }
}

resource "null_resource" "placeholder" {
  provisioner "local-exec" {
    command = "echo 'placeholder'"
  }
}
