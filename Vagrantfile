Vagrant.configure("2") do |config|
  config.vm.define :debian do |debian|
    debian.vm.box = "debian/jessie64"
    debian.vm.hostname = "faceless7171debian"
    debian.vm.network :private_network, ip: "192.168.0.1"

    debian.ssh.forward_agent = true
    debian.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y git
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh
      ssh-keyscan -H github.com >> ~/.ssh/known_hosts
      ssh -T git@github.com

      mkdir ~/proj
      git clone git@github.com:faceless7171/devops_training.git ~/proj

      cat ~/proj/module2_vms/module2.txt
    SHELL
  end

  config.vm.define :centos do |centos|
    centos.vm.box = "centos/7"
    centos.vm.hostname = "faceless7171centos"
    debian.vm.network :private_network, ip: "192.168.0.2"
  end
end
