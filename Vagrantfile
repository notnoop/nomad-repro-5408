# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  # work around a bug where file syncing is misbehaving in Mahmood's laptop
  config.vm.provision "shell", inline: "rm -rf /tmp/vagrant"
  config.vm.provision "file", source: ".", destination: "/tmp/vagrant/"

  config.vm.provider "virtualbox" do |_|
    config.vm.network :private_network, ip: "10.200.1.2"
  end

  config.vm.provision "shell", inline: <<-SHELL
    set -ex

    # install utility/dev tools
    yum install -y wget curl unzip vim tmux

    # install nomad
    if [ ! -e /usr/bin/nomad ]
    then
      readonly nomad_version=0.8.7
      curl -sSL -o /tmp/nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip
      unzip -d /usr/bin /tmp/nomad.zip
      rm -rf /tmp/nomad.zip
    fi

    # install golang
    if [ ! -e /usr/local/go/bin/go ]
    then
      readonly golang_version=1.12.1
      curl -sSL -o /tmp/golang.tar.gz https://dl.google.com/go/go${golang_version}.linux-amd64.tar.gz
      tar -C /usr/local -xzf /tmp/golang.tar.gz
      rm -rf /tmp/golang.tar.gz
    fi

    # compile hellosignal and place it in place accessible by raw_exec
    /usr/local/go/bin/go build -o /bin/hello-signals /tmp/vagrant/main.go
SHELL
end
