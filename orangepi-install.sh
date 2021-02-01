#!/bin/bash

# Orange pi install

# --------------------------- Test des droits
if [ $USER != "root" -o $UID != 0 ]
then
  echo "need sudo !"
  exit 1
fi

# --------------------------- update

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install timedatectl -y
# enable auto synchro
timedatectl set-ntp true
timedatectl set-timezone Europe/Paris

# --------------------------- LAMP

sudo apt-get install apache2 php mysql-server phpmyadmin 
sudo chmod -R 777 /var/www 


# --------------------------- python

sudo apt-get install build-essential libssl-dev libffi-dev python-dev

sudo apt-get install python3-pip -y
sudo apt-get upgrade pip3 -y
sudo pip3 install cherrypy
sudo pip3 install weather-api
sudo pip3 install geotext
pip3 install opencv-python

sudo apt-get install python3-serial

#sudo pip3 install pika
#sudo pip3 install pymongo

# --------------------------- git

sudo apt-get install git-core gitk

git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto

git config --global user.name "john"
git config --global user.email aa@email.com
#vim ~/.gitconfig

# --------------------------- nmap

sudo apt-get install nmap -y
# nmap -T4 -sP 192.168.1.0/24

# --------------------------- Installation WiringPi

#sudo apt-get install git-core
#cd /home/pi/
#sudo git clone git://git.drogon.net/wiringPi
#cd /home/pi/wiringPi
#sudo ./build


# --------------------------- moc vlc ffmpeg

#sudo apt-get install moc
#sudo apt-get install Vlc
#sudo apt-get install ffmpeg


# ---------------------------lancer un script au demarrage 

#rendre votre script executable : sudo chmod +x /var/www/action_domotix/autostart_domotix.py
#éditer le fichier /etc/rc.local : sudo nano /etc/rc.local
#ajouter avant exit 0 : 
#	sleep(20)
#	python /var/www/domotix.py


# --------------------------- droit root a www

#sudo nano /etc/sudoers
#www-data ALL=(ALL) NOPASSWD: ALL


# --------------------------- connexion ssh without password to b@B 

# ssh-keygen -t rsa
# ssh b@B mkdir -p .ssh
# cat .ssh/id_rsa.pub | ssh b@B 'cat >> .ssh/authorized_keys'
# ssh b@B




