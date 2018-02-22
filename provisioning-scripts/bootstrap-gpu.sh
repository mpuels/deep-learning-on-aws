#!/bin/bash

USER_=ubuntu
SSL_DIR=/home/${USER_}/ssl
JUPYTER_PASSWORD_FILE=/vagrant/jupyter-password.txt
JUPYTER_PASSWORD_HASH_FILE=${SSL_DIR}/jupyter-password-hash.txt

main() {
    su ${USER_} -c "generate_ssl_certs ${SSL_DIR}"

    su ${USER_} -c "generate_password_hash_for_jupyter_server \
                        ${JUPYTER_PASSWORD_FILE} \
                        ${JUPYTER_PASSWORD_HASH_FILE}"

    su ${USER_} -c "write_jupyter_notebook_config_py \
                        ${USER_} \
                        ${SSL_DIR} \
                        ${JUPYTER_PASSWORD_HASH_FILE}"

    start_jupyter_on_each_boot

    su ${USER_} -c "start_jupyter_now"

    print_next_step_message
}

generate_ssl_certs() {
    local ssl_dir=$1

    printf "Generating SSL certificate ${ssl_dir}/cert.pem.\n"
    mkdir -p ${ssl_dir}
    pushd ${ssl_dir}
    openssl req -x509 -nodes -days 365 -newkey rsa:1024 \
            -keyout "cert.pem" -out "cert.pem" -batch 2> /dev/null
    popd
}

export -f generate_ssl_certs

generate_password_hash_for_jupyter_server() {
    local jupyter_password_file=$1; shift
    local jupyter_password_hash_file=$1

    printf "Writing hash of ${jupyter_password_file} into "
    printf "${jupyter_password_hash_file}\n"

    local jupyter_password=$(cat ${jupyter_password_file})

    python -c "from IPython.lib import passwd; \
               print(passwd('${jupyter_password}'))" \
           > ${jupyter_password_hash_file}
}

export -f generate_password_hash_for_jupyter_server

write_jupyter_notebook_config_py() {
    local user=$1; shift
    local ssl_dir=$1; shift
    local jupyter_password_hash_file=$1

    printf "Writing file /home/${user}/.jupyter/jupyter_notebook_config.py.\n"

    local jupyter_password_hash=$(cat ${jupyter_password_hash_file})

    mkdir -p "/home/${user}/.jupyter"
    cat > "/home/${user}/.jupyter/jupyter_notebook_config.py" <<EOF
c = get_config()  # Get the config object.
c.NotebookApp.certfile = u'${ssl_dir}/cert.pem'
c.NotebookApp.keyfile = u'${ssl_dir}/cert.pem'
c.IPKernelApp.pylab = 'inline'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.password = '${jupyter_password_hash}'
EOF
}

export -f write_jupyter_notebook_config_py

start_jupyter_on_each_boot() {
    local cron_d_cmd="@reboot ubuntu cd /home/ubuntu; source /home/ubuntu/.bashrc; /home/ubuntu/anaconda3/bin/jupyter notebook >> /home/ubuntu/jupyter.log 2>&1"

    printf "Writing entry to /etc/cron.d/jupyter_notebook to start Jupyter "
    printf "server on each boot.\n"

    echo ${cron_d_cmd} > /etc/cron.d/jupyter_notebook
}

start_jupyter_now() {
    printf "Starting Jupyter server.\n"

    pushd /home/ubuntu > /dev/null
    source /home/ubuntu/.bashrc
    /home/ubuntu/anaconda3/bin/jupyter notebook >> /home/ubuntu/jupyter.log 2>&1 &

    printf "Jupyter server started. Writing log messages to "
    printf "/home/ubuntu/jupyter.log.\n"
}

export -f start_jupyter_now

print_next_step_message() {
    printf "EC2 machine is ready. Now on your local machine run "
    printf "forward_port_for_jupyter.bash, then point your browser to "
    printf "https://127.0.0.1:8157 to connect to the remote Jupyter server. As "
    printf "password enter the one you set in "
    printf "provisioning-scripts/jupyter-password.txt.\n"
}

main
