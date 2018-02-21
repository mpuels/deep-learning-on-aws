#!/bin/bash

main() {
    echo running
    ec2_is_running < test_data/test_data_vagrant_status_machine_readable_running.txt
    echo $?

    echo stopping
    ec2_is_running < test_data/test_data_vagrant_status_machine_readable_stopping.txt
    echo $?

    echo stopped
    ec2_is_running < test_data/test_data_vagrant_status_machine_readable_stopped.txt
    echo $?
}

ec2_is_running() {
    grep -q '[0-9]\+,[^,]\+,state,running$'
}

main
