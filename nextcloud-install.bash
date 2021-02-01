#!/bin/bash

# --- use ---
# chmod +x ./nextcloud-install.bash && sudo ./nextcloud-install.bash

############### config ###############

nextcloud_download_url="https://download.nextcloud.com/server/releases/"
nextcloud_folder="nextcloud-20.0.4.zip"
nextcloud_path="/var/www/html"

php_ini_path=/etc/php/7.3/apache2/php.ini
fpm_ini_path=/etc/php/7.3/fpm/pool.d/www.conf
mysql_ini_path=/etc/mysql/conf.d/mysql.cnf

db_name="nextcloud_ALUTD"
db_user="nextcloud_fred"
db_password="NmnMJOJc6DsclXyo"

nextcloud_user="fred"
nextcloud_password="pass"
nextcloud_dns="192.168.179.138"

dev_install=1
if [ $dev_install -eq 1 ]; then
  nextcloud_dns=ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tail -n1 | awk '{print $1}'
fi

######################################

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sudo apt update

# --- get errors ---
set -e
err_report() {
    echo "Error on line $1"
}
trap 'err_report $LINENO' ERR

# --- php conf ---

sudo apt install apache2 mariadb-server zip -y
sudo apt install libapache2-mod-php7.3 php7.3-gd php7.3-mysql php7.3-curl php7.3-mbstring php7.3-intl -y
sudo apt install php7.3-gmp php7.3-bcmath php-imagick php7.3-xml php7.3-zip php-json php-apcu php-redis php-ldap php-fpm  -y
# Install Redis  
apt-get install redis-server -y  
# Enable Apache extensions
a2enmod proxy_fcgi setenvif  
a2enmod rewrite 
a2enmod env  
a2enmod dir  
a2enmod mime  
a2enmod headers 
/etc/init.d/apache2 restart

cp $php_ini_path $php_ini_path".bak"
grep '^post_max_size ' $php_ini_path
sed -i 's/^upload_max_filesize =.*$/upload_max_filesize = 2G/' $php_ini_path
sed -i 's/^post_max_size =.*$/post_max_size = 2G/' $php_ini_path
sed -i 's/^memory_limit =.*$/memory_limit = 512M/' $php_ini_path
sed -i "s/^max_input_time/#max_input_time/g" $php_ini_path
sed -i "s/^max_execution_time/#max_execution_time/g" $php_ini_path
grep '^post_max_size ' $php_ini_path

echo '
apc.enabled_cli=1
opcache.enable=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
' >> $php_ini_path

echo "
pm = dynamic
pm.max_children = 120
pm.start_servers = 12
pm.min_spare_servers = 6
pm.max_spare_servers = 18
" >> $fpm_ini_path

echo "
[mysqld]
innodb-file-format=barracuda
innodb-file-per-table=1
innodb-large-prefix=1
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
innodb_buffer_pool_size=1G
innodb_io_capacity=4000
innodb_default_row_format = 'DYNAMIC'
" >> $mysql_ini_path

/etc/init.d/mysql restart
/etc/init.d/apache2 restart

# --- mysql conf ---

sudo mysql -u root -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;"

# --- get nextcloud ---
cd $nextcloud_path
wget $nextcloud_download_url$nextcloud_folder
unzip $nextcloud_folder
rm $nextcloud_folder
cd nextcloud
chown -R www-data .
chmod -R 777 .
sudo -u www-data php occ maintenance:install --database "mysql" --database-name "$db_name" --database-user "$db_user" --database-pass "$db_password" --admin-user "$nextcloud_user" --admin-pass "$nextcloud_password"
chmod -R 777 .

# Enable Redis memory caching  
sed -i '$i'"'"'memcache.local'"'"' => '"'"'\\OC\\Memcache\\Redis'"'"',''' $nextcloud_path/nextcloud/config/config.php  
sed -i '$i'"'"'memcache.locking'"'"' => '"'"'\\OC\\Memcache\\Redis'"'"',''' $nextcloud_path/nextcloud/config/config.php  
sed -i '$i'"'"'redis'"'"' => array('"\n""'"'host'"'"' => '"'"'localhost'"'"','"\n""'"'port'"'"' => 6379,'"\n"'),''' $nextcloud_path/nextcloud/config/config.php  
sed -i "s/0 => 'localhost'/0 => '$nextcloud_dns'/g" $nextcloud_path/nextcloud/config/config.php

# correct errors
sudo -u www-data php occ db:add-missing-indices

if [ $dev_install -eq 1 ]; then
    echo "
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/nextcloud

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        <Directory $nextcloud_path/nextcloud/>
            Options +FollowSymlinks
            AllowOverride All
            <IfModule mod_dav.c>
                Dav off
            </IfModule>
            SetEnv HOME $nextcloud_path/nextcloud/
            SetEnv HTTP_HOME $nextcloud_path/nextcloud/
        </Directory>
    </VirtualHost>
    " > /etc/apache2/sites-available/000-default.conf
#else
#    touch /etc/apache2/sites-available/nextcloud.conf  
#    echo "
#    <VirtualHost *:80>
#        ServerName $nextcloud_dns
#        Alias /nextcloud
#        <Directory $nextcloud_path/nextcloud/>
#            Options +FollowSymlinks
#            AllowOverride All
#            <IfModule mod_dav.c>
#                Dav off
#            </IfModule>
#            SetEnv HOME $nextcloud_path/nextcloud/
#            SetEnv HTTP_HOME $nextcloud_path/nextcloud/
#            ErrorLog ${APACHE_LOG_DIR}/error.log
#            CustomLog ${APACHE_LOG_DIR}/access.log combined
#        </Directory>
#    </VirtualHost>
#    " > /etc/apache2/sites-available/nextcloud.conf  
#    sudo a2ensite nextcloud
fi


/etc/init.d/mysql restart
/etc/init.d/apache2 restart

echo
sudo -u www-data php occ status
echo "
###########################
# Successful installation #
###########################
"

exit 

##################################################################################################

add in nextcloud apache /etc/apache2/sites-available/nextcloud.conf or .htaccess
```
<VirtualHost *:80>
   ServerName n.sjtm.fr
   Redirect permanent / https://cloud.nextcloud.com/
</VirtualHost>
<VirtualHost *:443>
    ServerName cloud.nextcloud.com
    <IfModule mod_headers.c>
      Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
    </IfModule>
    <Directory $nextcloud_path/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
        SetEnv HOME $nextcloud_path/nextcloud/
        SetEnv HTTP_HOME $nextcloud_path/nextcloud/
    </Directory>
 </VirtualHost>
```

# execute to scan files
sudo chown -R www-data .
sudo chmod -R 777 .
sudo -u www-data php occ files:scan --all

# to update password
sudo -u www-data php occ user:resetpassword fred
sudo -u www-data php occ config:system:set dbpassword --value "jyTZIaob62Hda"


# Enable NextCloud cron job every 15 minutes  
crontab -u www-data -l > cron  
echo "*/15 * * * * php -f /var/www/html/cron.php" >> cron  
crontab -u www-data cron  
rm cron  

# Set up cron job for certificate auto-renewal every 90 days  
crontab -l > cron  
echo "* 1 * * 1 /etc/certbot/certbot-auto renew --quiet" >> cron  
crontab cron  
rm cron  