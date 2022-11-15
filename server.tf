# Creates spot instances
resource "aws_spot_instance_request" "rabbitmq" {
  ami                       = data.aws_ami.my_ami.id
  instance_type             = "t3.micro"
  wait_for_fulfillment      = true 
  vpc_security_group_ids    = [aws_security_group.allow_rabbitmq.id]
  subnet_id                 = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS[0]
  iam_instance_profile      = "b50-admin"

  tags = {
    Name = "rabbitmq-${var.ENV}"
  }
}


resource "null_resource" "application_deploy" {
    provisioner "remote-exec" {  
    connection {
        type     = "ssh"
        user     = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USERNAME"]
        password = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASSWORD"]
        host     =  aws_spot_instance_request.rabbitmq.private_ip
    }

        inline = [

        "ansible-pull -U https://github.com/b50-clouddevops/ansible.git -e COMPONENT=rabbitmq -e ENV=dev roboshop-pull.yml"
            ]
        }
    }
