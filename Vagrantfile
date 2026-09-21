Vagrant.configure("2") do |config|

  # ---------- Máquina WEB ----------
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/jammy64"
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "192.168.56.10"

    web.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 1
      vb.name = "practica1-web"
    end

    web.vm.provision "shell", path: "provisioning.sh"
  end

  # ---------- Máquina CLIENTE ----------
  config.vm.define "cliente" do |cli|
    cli.vm.box = "ubuntu/jammy64"
    cli.vm.hostname = "cliente"
    cli.vm.network "private_network", ip: "192.168.56.11"

    cli.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "practica1-cliente"
    end
  end

end