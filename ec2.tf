change some command

resource "aws_instance" "example" {
  ami                    = "ami-03bb6d83c60fc5f7c" # Specify the AMI ID for your instance
  instance_type          = "t2.micro"              # Specify the instance type (e.g., t2.micro, t2.small)
  key_name               = aws_key_pair.key-tf.key_name
iam_instance_profile = aws_iam_instance_profile.example_profile.name
vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
tags = {
    Name = "example-instance" # Add tags as needed for your instance
  }
}
resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("${path.module}/id_rsa.pub")
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  dynamic "ingress" {
    for_each = [22, 443, 80]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_iam_policy" "example_policy" {
  name        = "example_policy"
  description = "permission for ec2"


 	policy  = jsonencode ({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*",
      },
    ],
  })
}
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}
# Create an IAM instance profile
resource "aws_iam_instance_profile" "example_profile" {
  name = "example_profile"
  role = aws_iam_role.example_role.name
}
# Create IAM Role
resource "aws_iam_role" "example_role" {
  name = "example_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "ec2.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}





