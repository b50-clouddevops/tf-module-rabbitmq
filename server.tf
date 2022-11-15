# Creates spot instances
resource "aws_spot_instance_request" "spot" {
  ami                       = data.aws_ami.my_ami.id
  instance_type             = var.INSTANCE_TYPE
  wait_for_fulfillment      = true 
  vpc_security_group_ids    = [aws_security_group.allow_app.id]
  subnet_id                 = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS, count.index)
  iam_instance_profile      = "b50-admin"

  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}



