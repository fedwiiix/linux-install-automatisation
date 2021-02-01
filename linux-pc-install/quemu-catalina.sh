# quemu kvm install

# https://www.funkyspacemonkey.com/how-to-install-macos-catalina-on-linux
# https://computingforgeeks.com/how-to-run-macos-on-kvm-qemu/

# check compatibilité
grep -E -c "vmx|svn" /proc/cpuinfo

sudo apt -y install qemu qemu-kvm libvirt-daemon qemu-system qemu-utils python3 python3-pip bridge-utils virtinst libvirt-daemon-system virt-manager
sudo modprobe vhost_net 
lsmod | grep vhost # check
echo vhost_net | sudo tee -a /etc/modules
# Grant user the usage of kvm
#sudo adduser fred libvirt

# quemu catalina

git clone https://github.com/foxlet/macOS-Simple-KVM.git
cd macOS-Simple-KVM
./jumpstart.sh --catalina

qemu-img create -f qcow2 macOS.qcow2 50G

#Modify the basic.sh file and add below lines to the end.
echo "
    -drive id=SystemDisk,if=none,file=macOS.qcow2 \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
" >> ./basic.sh

# load
sudo ./basic.sh
# Import the setup into Virt-Manager

sudo ./make.sh --add



