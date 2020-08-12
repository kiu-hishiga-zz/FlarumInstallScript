#!/bin/bash -       
#title         :flarumInstallScript
#description   :Ce script sert à automatiser l'installation de flarum
#author		     :KiuHishiga - 
#date          :12/08/2020
#version       :1.0
#usage		     :sudo bash flaruminstall.sh
#notes         :Tested with Ubuntu 20.04 LTS
#==============================================================================

#Changez ci-dessous la configuration de la BDD
MY_DOMAIN_NAME=flarum
MY_EMAIL=exemple@exemple.fr
DB_NAME=flarum
DB_PSWD=flarumfr

SITES_AVAILABLE='/etc/apache2/sites-available/'

clear

echo "***************************************"
echo "*         FlarumScript install        *"
echo "*                                     *"  
echo "*            By: kiuhishiga           *"
echo "***************************************"

read -p "Êtes-vous sûr de vouloir installer Flarum ? (Y/n) " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt-get update
    sudo apt-get -y install apache2 mariadb-server mariadb-client
    sudo apt install -y php libapache2-mod-php php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-zip php-curl php-pear php-dev libmcrypt-dev  composer openssl


    sudo mkdir -p /var/www/html/$MY_DOMAIN_NAME
    cd /var/www/html/$MY_DOMAIN_NAME
    composer create-project flarum/flarum . --stability=beta

    sudo chown -R www-data:www-data /var/www/html/$MY_DOMAIN_NAME    

    sudo echo " <VirtualHost *:80>
                    ServerAdmin $MY_EMAIL
                    ServerName $MY_DOMAIN_NAME
                    ServerAlias www.$MY_DOMAIN_NAME
                    DocumentRoot /var/www/html/$MY_DOMAIN_NAME/public
                    <Directory /var/www/html/$MY_DOMAIN_NAME/public>                    
                        AllowOverride all
                    </Directory>
                    ErrorLog /var/log/apache2/$MY_DOMAIN_NAME-error.log
                    LogLevel error
                    CustomLog /var/log/apache2/$MY_DOMAIN_NAME-access.log combined
		        </VirtualHost>" > $SITES_AVAILABLE$MY_DOMAIN_NAME.conf

    sudo a2ensite $MY_DOMAIN_NAME
    sudo a2enmod rewrite
    sudo a2dissite 000-default.conf
    sudo systemctl restart apache2

    sudo chmod -R 775 /var/www/html/$MY_DOMAIN_NAME

    sudo mysql -uroot -p$DB_PSWD -e "CREATE DATABASE $DB_NAME"
    sudo mysql -uroot -p$DB_PSWD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'localhost' IDENTIFIED BY '$DB_PSWD'"
else
    clear
fi
