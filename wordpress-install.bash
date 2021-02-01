#!/bin/bash -e
clear
echo "
============================================
WordPress Install Script
============================================

- warning all files will be installed in this path
"

echo "Database Name: "
read -e dbname
echo "Database User: "
read -e dbuser
echo "Database Password: "
read -s dbpass

echo "Wordpress Title: "
read -e wptitle
echo "Wordpress User: "
read -e wpuser
echo "Wordpress Password: "
read -s wppass
echo "Wordpress Email: "
read -e wpemail
echo "Wordpress Url: "
read -e wpurl

echo "
============================================
WordPress Install plugins
============================================
"
# plugin list
plugins_list=( wordpress-seo elementor imagify wps-cleaner wp-statistics wp-super-cache duplicator one-click-demo-import wpforms-lite really-simple-ssl better-wp-security all-404-redirect-to-homepage )

for i in "${plugins_list[@]}"
do
	echo " - $i"
done
echo ""
echo "run install of plugins (y/n)"
read -e run_plugins_install

echo "
============================================
WordPress cli Install
============================================
"
# chech wp cli install
wp --version
if [ $? != 0 ] ; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    wp --info
fi

echo "
============================================
creating db
============================================
"
# create db
sudo mysql -u root -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
CREATE DATABASE IF NOT EXISTS $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;"

echo "
============================================
installing WordPress
============================================
"
wp core download --locale=fr_FR
wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbhost=localhost --dbprefix=wpo_ 
# wp db create
wp core install --url=$wpurl --title=$wptitle --admin_user=$wpuser --admin_password=$wppass --admin_email=$wpemail

if [ "$run_plugins_install" == y ] ; then
    echo "========================="
    echo "Install plugins."
    echo "========================="
    
    # install
    for i in "${plugins_list[@]}"
    do
        wp plugin install $i
    done
fi

echo "
=========================
Installation updates
=========================
"
wp core update
wp plugin update --all

echo "
=========================
Finalize
=========================
"

sudo chown -R www-data .
rm wp-install.bash
# rollback - shopt -s extglob ; rm -r !(wp-install.bash)

echo "
=========================
Installation is complete.
=========================
"
