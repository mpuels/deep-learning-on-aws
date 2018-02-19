#!/bin/bash

# Forward local port with ssh to connect to remote Jupyter notebook
#
# How to use this script:
#
#     $ vagrant up
#     $ ./forward_port_for_jupyter.bash
#     Open remote Jupyter notebook on local machine on http://127.0.0.1:8157

LOCAL_PORT=8157
REMOTE_PORT=8888

main() {
    local remote_hostname=$(get_remote_hostname)
    local identity_file=$(get_identity_file)

    if remote_machine_is_not_running ${remote_hostname}; then
        echo "Error: Remote machine is not running."
        exit 1
    fi

    echo "Assuming Jupyter is running on ${remote_hostname}:${REMOTE_PORT}"
    echo "Identity file for authentication: ${identity_file}"
    echo "Jupyter notebook is available on http://127.0.0.1:${LOCAL_PORT}"

    ssh -i ${identity_file} \
        -L ${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT} \
        -o StrictHostKeyChecking=no \
        -o "UserKnownHostsFile /dev/null" \
        -o "LogLevel ERROR" \
        ubuntu@${remote_hostname}
}

get_remote_hostname() {
    vagrant ssh-config | grep HostName | cut -f4 -d' '
}

get_identity_file() {
    vagrant ssh-config | grep IdentityFile | cut -f4 -d' '
}

remote_machine_is_not_running() {
    local remote_hostname=$1
    echo ${remote_hostname} \
        | egrep -q '^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})'
}

main
