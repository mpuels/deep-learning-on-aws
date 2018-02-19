Vagrant.configure('2') do |config|
  # Run
  #
  #     $ vagrant box add aws-dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
  #
  # before running `vagrant up`.

  # Must be equal to `AWS_AVAILABILITY_ZONE` in ec2_ctl.py.
  aws_availability_zone = 'us-east-2c'

  # Key pair used to log in to EC2 instances.
  aws_keypair_name = 'deepfakes-on-aws' # Key pair's name on AWS.
  ssh_private_key_path = ENV['HOME'] + '/.ssh/deepfakes-on-aws.pem' # Private key.

  # AWS profile to use. Usually defined on host machine in ~/.aws/config.
  aws_aws_profile = 'marcpuels'

  # AWS role must be allowed to write to CloudWatch.
  aws_iam_instance_profile_name = 'deepfakes-role'

  # Must be `Group Name` of security group. Group must allow inbound SSH
  # connections and port 8888 must be open for the Jupyter notebook server.
  #aws_security_groups = ['deepfakes-on-aws']
  #aws_security_groups = ['deep-learning-with-python']
  aws_security_groups = ['sg-506bd53b']

  ssh_username = 'ubuntu'
  config.vm.synced_folder 'provisioning-scripts/', '/vagrant'

  config.vm.define 'gpu' do |gpu|
    gpu.vm.box = 'aws-dummy'
    gpu.vm.provision :shell, path: 'provisioning-scripts/bootstrap-gpu.sh'

    gpu.vm.provider :aws do |aws, override|
      aws.aws_profile = aws_aws_profile
      aws.keypair_name = aws_keypair_name

      aws.availability_zone = aws_availability_zone

      aws.ami = 'ami-82f4dae7' # Ubuntu Server 16.04 LTS (HVM),SSD Volume Type
      #aws.ami = 'ami-f0725c95' #  AWS Deep Learning.
      #aws.ami = 'ami-cd0f5cb6' #  AWS Deep Learning. Release Date 01/25/2018. Version 3.

      aws.iam_instance_profile_name = aws_iam_instance_profile_name

      aws.private_ip_address = '10.0.0.10'

      aws.subnet_id = 'subnet-d70c2e9a'

      aws.associate_public_ip = true

      aws.security_groups = aws_security_groups

      aws.tags = { 'Name' => 'deep-learning-with-python' }

      aws.instance_type = 't2.micro'
      #aws.instance_type = 'p2.xlarge' # 4 CPUs, 1 GPU, $0.9 per hour.

      override.ssh.username = ssh_username
      override.ssh.private_key_path = ssh_private_key_path
    end
  end
end
