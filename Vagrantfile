require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
cfg        = YAML.load_file("#{current_dir}/vagrant_config.yaml")


Vagrant.configure("2") do |config|
  config.vm.define :debian do |debian|
    debian.vm.box = "generic/ubuntu1804"
    debian.vm.hostname = cfg['vms']['debian']['hostname']
    debian.vm.network :private_network, ip: cfg['vms']['debian']['ip']
    
    debian.vm.synced_folder "./keys", "/home/vagrant/.ssh"
    debian.vm.synced_folder "./", "/vagrant"
    # ssh
    debian.vm.provision "shell", inline: <<-SHELL
      cp -rf /vagrant/sshdconfig /etc/ssh/sshd_config
    SHELL

    debian.vm.provision "shell", privileged: false, inline: <<-SHELL
      cp -rf /vagrant/sshconfig /home/vagrant/.ssh/config

      KEY_NAME="newkey"
      ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/$KEY_NAME
      eval "$(ssh-agent -s)"
      ssh-add /home/vagrant/.ssh/$KEY_NAME

      cp -a /home/vagrant/.ssh/$KEY_NAME.pub /vagrant/auth_keys

      cat /vagrant/auth_keys >> /home/vagrant/.ssh/authorized_keys
    SHELL

    debian.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y nmap curl parted

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

        file /bin/* | grep -i shell | cut -d: -f1 > bin.txt

        #wget -c https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.1.0-amd64-netinst.iso

        curl -O -L https://github.com/faceless7171/devops_training/archive/module3.zip -o module3.zip

        cat /proc/loadavg > la.txt
        df -h > hdd.txt
        ps aux > pl.txt
        cat /proc/swaps > swap.txt
        cat /proc/scsi/scsi > dev.txt
        lscpu > cpu.txt
        ps -fp 1 > 1.txt
        parted -l > parts.txt
        netstat -anp | grep :80 | grep ESTABLISHED
        nmap -sT -O google.com > ports.txt
        lsof -P -n -iTCP > tcp.txt
        lsof -P -n -iUDP > upd.txt
        netstat -nxp > usocket.txt
        netstat -rn > net.txt
        netstat -s > nstat.txt
        hostnamectl set-hostname newname
        cat /etc/resolv.conf | grep nameserver       
    SHELL
  end

  config.vm.define :debian2 do |debian2|
    debian2.vm.box = "generic/ubuntu1804"
    debian2.vm.hostname = cfg['vms']['debian2']['hostname']
    debian2.vm.network :private_network, ip: cfg['vms']['debian2']['ip']

    debian2.vm.synced_folder "./", "/vagrant"

    debian2.vm.provision "shell", inline: <<-SHELL
      cp -rf /vagrant/sshdconfig /etc/ssh/sshd_config
    SHELL

    debian2.vm.provision "shell", privileged: false, inline: <<-SHELL
      cp -rf /vagrant/sshconfig /home/vagrant/.ssh/config
      
      cp -rf /vagrant/auth_keys /home/vagrant/.ssh/authorized_keys

      systemctl restart sshd
    SHELL
  end
end
