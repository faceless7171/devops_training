require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
cfg        = YAML.load_file("#{current_dir}/vagrant_config.yaml")


Vagrant.configure("2") do |config|
  config.vm.define :ubuntu do |ubuntu|
    ubuntu.vm.box = "generic/ubuntu1804"
    ubuntu.vm.hostname = cfg['vms']['ubuntu']['hostname']
    ubuntu.vm.network :private_network, ip: cfg['vms']['ubuntu']['ip']
    
    ubuntu.vm.provision "shell", inline: <<-SHELL
      echo "ISSOFT_VAR=test" > /etc/environment
      chmod a+x /vagrant/scripts/*

      
      systemctl disable motd
      cp /vagrant/scripts/sysinfo.sh /etc/update-motd.d/00-header
    SHELL
  end
end
