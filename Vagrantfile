require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
cfg        = YAML.load_file("#{current_dir}/vagrant_config.yaml")


Vagrant.configure("2") do |config|
  config.vm.define :debian do |debian|
    debian.vm.box = "debian/jessie64"
    debian.vm.hostname = cfg['vms']['debian']['hostname']
    debian.vm.network :private_network, ip: cfg['vms']['debian']['ip']

    debian.vm.provision "shell", inline: <<-SHELL
        mkdir -p /home/vagrant/prod/random-old /home/vagrant/prod/old
        touch /home/vagrant/prod/random-old/{6..10}
        sudo cp -r --preserve=all /home/vagrant/prod/random-old /home/vagrant/prod/old

        mkdir -p /home/vagrant/prod/random-current /home/vagrant/prod/current
        touch /home/vagrant/prod/random-current/{1..4}
        sudo cp -r --no-preserve=all /home/vagrant/prod/random-current /home/vagrant/prod/current

        mkdir -p /home/vagrant/prod/random-new /home/vagrant/prod/new
        touch --date=$(date --date='1 year ago') /home/vagrant/prod/random-new/{1..4}
        sudo cp -r --preserve=timestamps /home/vagrant/prod/random-new /home/vagrant/prod/new

        tar -czvf /home/vagrant/folders.tar.gz /home/vagrant/prod/new /home/vagrant/prod/current /home/vagrant/prod/old

        

        wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.1.0-amd64-netinst.iso

        curl -L https://github.com/faceless7171/devops_training/archive/module3.zip -o mosule3.zip
    SHELL
  end

  config.vm.define :debian2 do |debian2|
    debian2.vm.box = "debian/jessie64"
    debian2.vm.hostname = cfg['vms']['debian2']['hostname']
    debian2.vm.network :private_network, ip: cfg['vms']['debian2']['ip']

    debian2.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y ntp ntpdate

      echo "server 192.168.50.1 prefer" > /etc/ntp.conf
      service ntp restart
      ntpq -p
      ntpdate -q 192.168.50.1
    SHELL
  end
end
