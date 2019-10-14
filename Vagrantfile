require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
cfg        = YAML.load_file("#{current_dir}/vagrant_config.yaml")

def get_hosts(vms)
  hosts = ""
  vms.each do |k,v|
    hosts << "\n#{v['ip']} #{v['hostname']}"
  end
  hosts
end
hosts = get_hosts(cfg['vms'])

Vagrant.configure("2") do |config|
  config.vm.define :debian do |debian|
    debian.vm.box = "debian/jessie64"
    debian.vm.hostname = cfg['vms']['debian']['hostname']
    debian.vm.network :private_network, ip: cfg['vms']['debian']['ip']

    debian.vm.provision "shell", inline: <<-SHELL
      echo "#{hosts}" >> /etc/hosts
    SHELL

    debian.ssh.forward_agent = true
    debian.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y git
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh
      ssh-keyscan -H github.com >> ~/.ssh/known_hosts
      ssh -T git@github.com

      mkdir -p /home/proj
      git clone -b module2 git@github.com:faceless7171/devops_training.git /home/proj

      cat /home/proj/module2.txt
    SHELL
  end

  config.vm.define :centos do |centos|
    centos.vm.box = "centos/7"
    centos.vm.hostname = cfg['vms']['centos']['hostname']
    centos.vm.network :private_network, ip: cfg['vms']['centos']['ip']

    centos.ssh.forward_agent = true
    centos.vm.provision "shell", inline: <<-SHELL
      echo "#{hosts}" >> /etc/hosts
    SHELL
  end
end
