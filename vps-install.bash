#!/bin/bash

# --- use ---
# chmod +x ./vps-install.bash && sudo ./vps-install.bash
# sudo bash <(sed -n '22,$p' vps-install.bash) for line 22

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# --- get errors ---
set -e
err_report() {
    echo "Error on line $1"
}
trap 'err_report $LINENO' ERR

apt update
apt upgrade -y

# --- install cron, curl, git ---
apt install cron curl git timedatectl -y

# enable auto synchro
timedatectl set-ntp true
timedatectl set-timezone Europe/Paris

# --- web server install ---
apt install apache2 -y
apt install php php-cgi php-mysqli php-pear php-mbstring php-gettext libapache2-mod-php php-common php-phpseclib php-mysql -y
apt install php-mysql php-curl php-json php-zip php-fpm -y
apt install mariadb-server -y # mariadb-client -y
mysql_secure_installation

# --- phpmyadmin ---
sudo apt install gpg -y
mkdir -p phpMyAdminDownloads
wget -P phpMyAdminDownloads https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
wget -P phpMyAdminDownloads https://files.phpmyadmin.net/phpmyadmin.keyring
wget -P phpMyAdminDownloads https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz.asc
cd phpMyAdminDownloads
gpg --import phpmyadmin.keyring
gpg --verify phpMyAdmin-latest-all-languages.tar.gz.asc
mkdir /var/www/html/phpmyadmin
tar xvf phpMyAdmin-latest-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin
cd ..
rm -r phpMyAdminDownloads/
randomBlowfishSecret=$(openssl rand -base64 32)
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" /var/www/html/phpmyadmin/config.sample.inc.php > /var/www/html/phpmyadmin/config.inc.php
chmod 660 /var/www/html/phpmyadmin/config.inc.php
chown -R www-data:www-data /var/www/html/phpmyadmin

# ------ config ------

# --- mariadb ---
echo "--- creation of a new user of mariadb ---"
read -p 'mariadb new user username: ' mariadb_user
read -sp 'mariadb new user password: ' mariadb_password
# add new user and config mysql
echo "enter mariadb root password"
mysql -u root -e "CREATE USER '$mariadb_user'@'localhost' IDENTIFIED BY '$mariadb_password';
GRANT ALL PRIVILEGES ON * . * TO '$mariadb_user'@'localhost';
FLUSH PRIVILEGES;"

# --- hide apache version in http header ---
sed -i 's/ServerTokens/\#ServerTokens/g' /etc/apache2/apache2.conf 
sed -i 's/ServerSignature/\#ServerSignature/g' /etc/apache2/apache2.conf 
echo "
ServerTokens Prod
ServerSignature Off 
" >> /etc/apache2/apache2.conf

# --- php config ---
echo "
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    #allow .htaccess
    <Directory /var/www/html>
        AllowOverride all
    </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf

php_ini_path=/etc/php/7.3/apache2/php.ini
cp $php_ini_path $php_ini_path".bak"
grep '^post_max_size ' $php_ini_path
sed -i 's/^upload_max_filesize =.*$/upload_max_filesize = 2G/' $php_ini_path
sed -i 's/^post_max_size =.*$/post_max_size = 2G/' $php_ini_path
sed -i 's/^memory_limit =.*$/memory_limit = 512M/' $php_ini_path
sed -i "s/^max_input_time/#max_input_time/g" $php_ini_path
sed -i "s/^max_execution_time/#max_execution_time/g" $php_ini_path
grep '^post_max_size ' $php_ini_path

systemctl restart apache2

# --- no ssh by root user ---
sed -i 's/Port/\#Port/g' /etc/apache2/apache2.conf 
sed -i 's/PermitRootLogin/\#PermitRootLogin/g' /etc/apache2/apache2.conf 
echo "
Port 22
PermitRootLogin no
" >> /etc/ssh/sshd_config

# --- add user ---
#adduser fred
#adduser fred sudo

# --- rkhunter ---
apt install rkhunter -y
sed -i 's/CRON_DAILY_RUN=.*/CRON_DAILY_RUN="yes"/g' /etc/default/rkhunter
read -p 'rkhunter email: ' rkhunter_email
sed -i "s/^MAIL-ON-WARNING=.*/#MAIL-ON-WARNING=/g" /etc/rkhunter.conf
sed -i "s/^#MAIL-ON-WARNING=.*/MAIL-ON-WARNING=$rkhunter_email/" /etc/rkhunter.conf

# --- fail2ban ---
apt install fail2ban -y
echo "
#[DEFAULT]
#ignoreip = 128.78.64.164

[sshd]
enabled = true
# 10 request in one hour min -> Ban ...
maxretry = 10
findtime = 3600
bantime = 9999999

[sshd-ddos]
enabled = true

[recidive]
enabled = true

[apache]
enabled = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 10

# the user is blocked for 10 minutes after 10 attempts in 2 minutes
#[apache-unauthorized]
#enabled = true
#filter = apache-unauthorized
#port = 80,443 # or http,https
#logpath = /var/log/apache2/access.log
#maxretry = 10
#findtime = 120
#bantime = 600
" > /etc/fail2ban/jail.d/defaults-debian.conf
service fail2ban start
fail2ban-client status
# list - sudo iptables -S

#  ---display versions ---
echo "
######## versions #########
"
php --version
/usr/sbin/apache2 -v
mysql --version

# --- finally restart ssh ---
sudo systemctl restart ssh

echo "
###########################
# Successful installation #
###########################
"

exit