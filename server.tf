# Creates spot instances
resource "aws_spot_instance_request" "spot" {
  count                     = var.SPOT_INSTANCE_COUNT  
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

# Creates On-Demand Servers
resource "aws_instance" "od" {
  count                     = var.OD_INSTANCE_COUNT 
  ami                       = data.aws_ami.my_ami.id
  instance_type             = var.INSTANCE_TYPE
  vpc_security_group_ids    = [aws_security_group.allow_app.id]
  subnet_id                 = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS, count.index)

  tags     = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}

# Adds tags to the ec2 servers. 
resource "aws_ec2_tag" "example" {
  count       = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  resource_id = element(local.ALL_INSTANCE_IDS, count.index)
  key         = "Name"
  value       = "${var.COMPONENT}-${var.ENV}"
}


