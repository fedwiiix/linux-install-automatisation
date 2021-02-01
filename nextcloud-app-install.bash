#!/bin/bash
# --- use ---
# chmod +x ./nextcloud-app-install.bash && sudo ./nextcloud-app-install.bash

# --- get errors ---
set -e
err_report() {
    echo "Error on line $1"
}
trap 'err_report $LINENO' ERR

apt install git -y

nextcloud_path=/var/www/nextcloud/
nextcloud_app_list="movies_collection","people"

cd $nextcloud_path/
IFS=',' read -r -a array <<< $nextcloud_app_list
for i in "${array[@]}"
do
    if [ -d "./apps/$i" ]; then
            echo "$update $i"
            git -C ./apps/$i pull
    else
            echo "install $i"
            git clone https://github.com/fedwiiix/$i.git ./apps/$i
    fi
    sudo -u www-data php occ app:enable $i --force
done

documentserver_community_url=https://github.com/nextcloud/documentserver_community/releases/download/v0.1.7/documentserver_community.tar.gz
cd
wget $documentserver_community_url
tar -xzvf documentserver_community.tar.gz
rm documentserver_community.tar.gz
if [ -d "$nextcloud_path/apps/documentserver_community" ]; then
  rm -r $nextcloud_path/apps/documentserver_community
fi
mv documentserver_community $nextcloud_path/apps
cd $nextcloud_path/
chown -R www-data .
chmod -R 777 .
sudo -u www-data php occ app:install onlyoffice
sudo -u www-data php occ app:enable documentserver_community --force

echo
sudo -u www-data php occ status
echo "
###########################
# Successful installation #
###########################

 - add in only office setting's address: https://nextcloud.sjtm.fr/index.php/apps/documentserver_community/
"

exit


nextcloud_path=/var/www/nextcloud/
cd $nextcloud_path

nextcloud_app="vps-backend-app"
git clone git@gitlab.com:fedwiiix/$nextcloud_app.git ./apps/$nextcloud_app
sudo -u www-data php occ app:enable $nextcloud_app --force 

nextcloud_app="people"
git clone git@github.com:fedwiiix/$nextcloud_app.git ./apps/$nextcloud_app
sudo -u www-data php occ app:enable $nextcloud_app --force 

nextcloud_app="movies_collection"
git clone git@github.com:fedwiiix/$nextcloud_app.git ./apps/$nextcloud_app
sudo -u www-data php occ app:enable $nextcloud_app --force 

sudo chown -R www-data .

sudo -u www-data php occ app:install calendar
sudo -u www-data php occ app:install drawio
sudo -u www-data php occ app:install tasks
sudo -u www-data php occ app:install apporder
sudo -u www-data php occ app:install drawio