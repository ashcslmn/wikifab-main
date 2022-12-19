# Wikifab Installation

Since the project has not been maintained for a long time, I am providing instructions on how to run wikifab on your own server using docker and compatible old versions of mediawiki, php, mysql. Everything is not 100% functional, but the basic functions work.

## Install Docker - https://docs.docker.com/engine/install/debian/
    apt-get remove docker docker-engine docker.io containerd runc
    
    apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

## Install Portainer CE - https://docs.portainer.io/start/install/server/docker/linux
    docker volume create portainer_data
    
    docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

    Login and create admin account at https://IP:9443

## Install MySQL
    docker run --name wikifab-mysql -e MYSQL_ROOT_PASSWORD=someSqlPassword -d mysql:5.7.40-debian

## Install latest compatible MediaWiki
    docker run --name wikifab -p 80:80 --link wikifab-mysql:mysql -d mediawiki:1.31.3

    Go to http://IP:80 and follow installation instructions
    
    SQL host is from Docker network something like 172.17.0.4
    
    MySQL default user root
    MySQL password set in the mysql install step

    Download LocalSettings.php and upload it into /var/www/html (nano /var/www/html/LocalSettings.php and paste file content)
    
## Install latest wikifab - !!! Paste commands in Portainer console of container wikifab !!!
    wget https://github.com/mat100/wikifab-main/archive/master.zip
    unzip master.zip
    cp -R wikifab-main-master/* /var/www/html/
    rm master.zip
    
    cd /var/www/html
    wget -cO - https://getcomposer.org/composer-1.phar > composer.phar
    php composer.phar config minimum-stability dev
    php composer.phar update --no-dev
    
    cd extensions
    wget -O tabber.zip  https://github.com/HydraWiki/Tabber/archive/master.zip
    unzip tabber.zip
    mv Tabber-master Tabber
    rm tabber.zip
    
    cd /var/www/html
    mv vendor/mediawiki/flow extensions/Flow
    
    echo "include('LocalSettings.wikifab.php');" >> LocalSettings.php
    
    php maintenance/update.php
    php maintenance/initWikifab.php --setWikifabHomePage --int

## Install dependencies for Export PDF - !!! Paste commands in Portainer console of container wikifab !!!
    apt install wget xvfb
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb
    apt install ./wkhtmltox_0.12.6-1.buster_amd64.deb

    echo "$wgGroupPermissions['*']['exportpdf'] = true;" >> LocalSettings.php
    echo "$wgPberWkhtmlToPdfExec = "xvfb-run /usr/local/bin/wkhtmltopdf";" >> LocalSettings.php
    
    php maintenance/update.php

## Install dependencies for image annotation  - !!! Paste commands in Portainer console of container wikifab !!!
    apt install inkscape
    
## TroubleShooting

To display errors messages, add the following lines on top of the LocalSettings.php file : 

error_reporting( -1 );
ini_set( 'display_errors', 1 );
$wgShowExceptionDetails = true;
