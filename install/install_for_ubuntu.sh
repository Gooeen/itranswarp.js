#!/bin/sh

if [ -d "/srv/itranswarp" ]; then
    echo "/srv/itranswarp is existed."
    exit
fi

sudo apt update
sudo apt -y upgrade
sudo apt install -y curl
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs memcached nginx imagemagick supervisor mysql-server
sudo npm install -g less less-watch-compiler gulp

sudo mkdir /srv/itranswarp/
sudo cp -rf ./* /srv/itranswarp/
sudo cp conf/supervisor/itranswarp.conf /etc/supervisor/conf.d/itranswarp.conf
sudo cp conf/nginx/itranswarp-without-ssl.conf /etc/nginx/conf.d/itranswarp-without-ssl.conf
sudo mkdir /var/cache/nginx/
sudo mkdir /var/log/itranswarp/
sudo touch /var/log/itranswarp/app.log
sudo touch /var/log/itranswarp/access_log
sudo touch /var/log/itranswarp/error_log

cd /srv/itranswarp/www/
sudo npm install
sudo node script/init-db.js
sudo rm /tmp/itranswarp-info.log
sudo nohup less-watch-compiler static/css/less static/css itranswarp.less
sleep 5s
sudo gulp

sudo supervisorctl reread
sudo supervisorctl reload
sudo service nginx restart
