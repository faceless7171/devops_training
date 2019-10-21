require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
cfg        = YAML.load_file("#{current_dir}/vagrant_config.yaml")


Vagrant.configure("2") do |config|
  config.vm.define :debian do |debian|
    debian.vm.box = "debian/jessie64"
    debian.vm.hostname = cfg['vms']['debian']['hostname']
    debian.vm.network :private_network, ip: cfg['vms']['debian']['ip']

    debian.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common
      curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
      echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list

      apt-get install docker
    SHELL

    debian.vm.provision "shell", inline: <<-SHELL
      groupadd newgroup
      useradd -m newuser
      usermod -a -G newgroup newuser
      delgroup newgroup

      echo "newuser ALL=/sbin/service ssh restart" >> /etc/sudoers
    SHELL

    debian.vm.provision "shell", inline: <<~SHELL
        echo '[Unit]
        Description=Test service
        Requires=network.target
        After=network.target
        
        [Service]
        Type=oneshot
        Environment="TIME_DATE=$(/bin/date +%%s)"
        ExecStart=/bin/sh -c "/usr/bin/touch /home/vagrant/service_created${TIME_DATE}"
        ExecStart=/bin/sh -c "/usr/bin/dig google.com > /home/vagrant/google${TIME_DATE}"

        [Install]
        WantedBy=multi-user.target' >> /etc/systemd/system/my_service.service

        systemctl enable my_service.service
    SHELL

    debian.vm.provision "shell", inline: <<~SHELL
      apt-get update
      apt-get install -y ntp ntpdate

      echo "restrict 192.168.50.0 mask 255.255.255.0 nomodify notrap
      server 127.127.1.0 # локальные часы
      fudge 127.127.1.0 stratum 10
      logfile /var/log/ntp.log" >>  /etc/ntp.conf

      service ntp restart
      update-rc.d ntp defaults
      ntpdate -q 127.0.0.1
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
