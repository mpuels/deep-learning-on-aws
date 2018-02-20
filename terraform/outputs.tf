output "security_group_id" {
  value = "${aws_security_group.allow_all.id}"
}

output "subnet_id" {
  value = "${aws_subnet.main.id}"
}

output "aws_profile" {
  value = "${var.profile}"
}

output "availability_zone" {
  value = "${var.availability_zone}"
}

output "instance_profile" {
  value = "${aws_iam_instance_profile.deep_learning.name}"
}

output "keypair_name" {
  value = "${var.keypair_name}"
}

output "ssh_private_key_path" {
  value = "${var.ssh_private_key_path}"
}

output "aws_ami" {
  value = "${var.aws_ami}"
}

output "aws_instance_type" {
  value = "${var.aws_instance_type}"
}
