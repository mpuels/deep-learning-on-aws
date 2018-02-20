provider "aws" {
  version = "~> 1.9"
  profile = "${var.profile}"
  region = "${var.region}"
}

# TODO aws_iam_instance_profile_name = 'deepfakes-role'


# TODO aws_security_groups = ['deepfakes-on-aws']
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "allow_all" {
  name        = "deep-learning-with-python"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jupyter server"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    #prefix_list_ids = ["pl-12c4e678"]
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/16"
  map_public_ip_on_launch = "1"
  availability_zone = "${var.availability_zone}"

  tags {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "main"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_iam_instance_profile" "deep_learning" {
  name  = "${aws_iam_role.deep_learning.name}"
  role = "${aws_iam_role.deep_learning.name}"
}

resource "aws_iam_role" "deep_learning" {
  name = "deep_learning"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloud_watch_put_metric_data" {
  name = "cloud-watch-put-metric-data"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "cloudwatch:PutMetricData"
          ],
          "Effect": "Allow",
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "deep_learning_cloud_watch_put" {
    role       = "${aws_iam_role.deep_learning.name}"
    policy_arn = "${aws_iam_policy.cloud_watch_put_metric_data.arn}"
}
