# Setting up Jupyter on AWS EC2 for remote access

Create SSL certificates:

    remote:~$ mkdir ssl
    remote:~$ cd ssl
    remote:~/ssl$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout "cert.pem" -out "cert.pem" -batch

Generate hash for password 'mysecretpassword' for Jupyter
notebook. Choose your password:

    remote:~$ python -c "from IPython.lib import passwd; print(passwd('mysecretpassword'))"
    # sha1:43c6a1912ffd:32d8e13........

On remote machine append to file `~/.jupyter/jupyter_notebook_config.py`:

    c = get_config()  # Get the config object.
    c.NotebookApp.certfile = u'/home/ubuntu/ssl/cert.pem' # path to the certificate we generated
    c.NotebookApp.keyfile = u'/home/ubuntu/ssl/cert.pem' # path to the certificate key we generated
    c.IPKernelApp.pylab = 'inline'  # in-line figure when using Matplotlib
    c.NotebookApp.ip = '*'  # Serve notebooks locally.
    c.NotebookApp.open_browser = False  # Do not open a browser window by default when using notebooks.
    c.NotebookApp.password = 'sha1:43c6a1912ffd:32d8e13........'

