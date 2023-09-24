#creating ssh key 

resource "aws_key_pair" "key-tf" {
  key_name   = "${var.key_name}"
  public_key = file("${path.module}/id_rsa.pub")
}

#Creating Security group

resource "aws_security_group" "allow_public_traffic" {
  name        = "${var.sg_name}"
  description = "Allow ssh inbound traffic"

  dynamic "ingress" {
    for_each = [80, 443, 22]
    iterator = port
    content {
      description = "ssh from anywhere"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_instance" "instance" {
  ami                    = "ami-05552d2dcf89c9b24"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key-tf.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_public_traffic.id}"]
  tags = {
    Name = "${var.instance_name}"
  }
}