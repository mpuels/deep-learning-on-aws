#!/bin/bash

main() {
    SECURITY_GROUP_ID=$(tfo security_group_id) \
                     SUBNET_ID=$(tfo subnet_id) \
                     AWS_PROFILE=$(tfo aws_profile) \
                     AVAILABILITY_ZONE=$(tfo availability_zone) \
                     INSTANCE_PROFILE=$(tfo instance_profile) \
                     KEYPAIR_NAME=$(tfo keypair_name) \
                     SSH_PRIVATE_KEY_PATH=$(tfo ssh_private_key_path) \
                     AWS_AMI=$(tfo aws_ami) \
                     AWS_INSTANCE_TYPE=$(tfo aws_instance_type) \
                     vagrant $@
}

tfo() {
    pushd terraform > /dev/null
    terraform output $1
    popd > /dev/null
}

main $@
