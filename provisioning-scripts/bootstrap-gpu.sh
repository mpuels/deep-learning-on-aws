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

    # /etc/cron.d/jupyter_notebook:
    #@reboot ubuntu cd /home/ubuntu; source /home/ubuntu/.bashrc; /home/ubuntu/anaconda3/bin/jupyter notebook >> /home/ubuntu/jupyter.log 2>&1
}

generate_ssl_certs() {
    local ssl_dir=$1

    printf "Generating SSL certificate ${ssl_dir}/cert.pem.\n"
    mkdir -p ${ssl_dir}
    pushd ${ssl_dir}
    openssl req -x509 -nodes -days 365 -newkey rsa:1024 \
            -keyout "cert.pem" -out "cert.pem" -batch
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

main
