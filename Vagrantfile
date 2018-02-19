Vagrant.configure('2') do |config|
  # Run
  #
  #     $ vagrant box add aws-dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
  #
  # before running `vagrant up`.
  config.vm.synced_folder 'provisioning-scripts/', '/vagrant'

  config.vm.define 'gpu' do |gpu|
    gpu.vm.box = 'aws-dummy'
    gpu.vm.provision :shell, path: 'provisioning-scripts/bootstrap-gpu.sh'

    gpu.vm.provider :aws do |aws, override|
      aws.aws_profile = ENV['AWS_PROFILE']
      aws.keypair_name = ENV['KEYPAIR_NAME']

      aws.availability_zone = ENV['AVAILABILITY_ZONE']

      aws.ami = ENV['AWS_AMI']

      aws.iam_instance_profile_name = ENV['INSTANCE_PROFILE']

      aws.subnet_id = ENV['SUBNET_ID']

      aws.associate_public_ip = true

      aws.security_groups = [ENV['SECURITY_GROUP_ID']]

      aws.tags = { 'Name' => 'deep-learning' }

      aws.instance_type = ENV['AWS_INSTANCE_TYPE']

      override.ssh.username = 'ubuntu'
      override.ssh.private_key_path = ENV['SSH_PRIVATE_KEY_PATH']
    end
  end
end
