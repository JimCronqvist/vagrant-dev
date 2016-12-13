# -*- mode: ruby -*-
# vi: set ft=ruby :

def running_in_admin_mode?
    return false unless Vagrant::Util::Platform.windows?
    (`reg query HKU\\S-1-5-19 2>&1` =~ /ERROR/).nil?
end

if Vagrant::Util::Platform.windows? && !running_in_admin_mode?
	raise Vagrant::Errors::VagrantError.new, "You must run Vagrant from an elevated command prompt"
end

if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*").empty? || ARGV[1] == '--provision'
    print "Please specify a hostname for your web server, for example `dev.example.com` \n"
    print "Hostname: "
    apache_host = STDIN.gets.chomp
    print "\n"
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443
  config.vm.network "forwarded_port", guest: 3306, host: 3306
  
  # Create a private network, which allows host-only access to the machine using a specific IP.
  #config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network. Bridged networks make the machine appear as another physical device on your network.
  #config.vm.network "public_network"

  config.vm.synced_folder "../", "/var/www"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
	# Please note that the following line has proven to be necessary in order to have a working internet connection on the guest before and during the initial provisioning phase
	vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
  
  config.vm.provision "shell", path: "bootstrap.sh", env: {"APACHE_HOST" => apache_host}
end
