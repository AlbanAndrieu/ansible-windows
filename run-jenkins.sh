#!/bin/bash
set -xv
echo "USER : $USER"
echo "HOME : $HOME"
echo "WORKSPACE : $WORKSPACE"

#scl enable python27 bash
export PATH="/opt/rh/python27/root/usr/bin:/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
export LD_LIBRARY_PATH="/opt/rh/python27/root/usr/lib64"

#alias python='/opt/rh/python27/root/usr/bin/python2.7'

#wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
#dpkg -i vagrant_1.6.3_x86_64.deb

#vagrant plugin install vagrant-winrm
#vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-login
vagrant plugin uninstall vagrant-windows
vagrant plugin uninstall vagrant-lxc
vagrant plugin uninstall vagrant-vbguest
vagrant plugin uninstall vagrant-winrm

vagrant plugin list
#vagrant plugin update

python -V
python2.7 -V

pip -V

ansible --version

vagrant --version

VBoxManage --version

echo "Configure Jenkins slaves windows"

cd Scripts/ansible/roles/windows

VBoxManage list vms

VBoxManage controlvm vagrant-windows-2012 poweroff || true
VBoxManage unregistervm vagrant-windows-2012 --delete || true
#VBoxManage modifyvm vagrant-windows-2012 --longmode off
#vagrant up --debug || exit 1
vagrant up || exit 1
#vagrant box update
#vagrant provision
#ssh-keygen -f "/home/jenkins/.ssh/known_hosts" -R [10.21.22.69]:2233
#ssh -p 2233 vagrant@10.21.22.69 "cd buildmasters/Scripts/ansible/roles/windows ; vagrant up"
#sudo ansible-playbook -i hosts -c local -v windows.yml -vvvv

#vagrant winrm-config
#vagrant winrm global-status

echo "Check log at /home/jenkins/VirtualBox\ VMs/vagrant-windows-2012/Logs/VBox.log"
