#!/bin/bash

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

#!/bin/bash
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
echo "deb http://repo.pritunl.com/stable/apt trusty main" > /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv EA312927
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv CF8E292A
apt-get --assume-yes update
apt-get --assume-yes upgrade
apt-get --assume-yes install pritunl mongodb-org
service pritunl start

#Install Nano
apt-get -y install nano

# Install Squid
apt-get -y install squid
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.orig
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/asyrafazhan/AUTO-PRITUNL/master/conf/squid.conf" 
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
sed -i s/xxxxxxxxx/$MYIP/g /etc/squid3/squid.conf;
service squid3 restart

# Enable Firewall
apt-get -y install ufw
sudo ufw allow 22,53,80,81,222,443,8080,9700,65000,60020,1194/tcp
sudo ufw allow 22,53,80,81,222,443,8080,9700,65000,60020,1194/udp
sudo yes | ufw enable
wget -O /etc/iptables.up.rules "https://raw.github.com/asyrafazhan/AUTO-PRITUNL/master/conf/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.d/rc.local
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
service openvpn restart

# Change to Time GMT+8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# Install Web Server
apt-get -y install nginx php5-fpm php5-cli
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/asyrafazhan/AUTO-PRITUNL/master/conf/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by AsyrafAzhan </pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/asyrafazhan/AUTO-PRITUNL/master/conf/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# Install Vnstat
apt-get -y install vnstat
vnstat -u -i eth0
sudo chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

# Install Vnstat GUI
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# About
clear
echo "Script ini hanya mengandungi :-"
echo "-Pritunl"
echo "-MongoDB"
echo "-Vnstat"
echo "-Web Server"
echo "-Squid Proxy Port 65000/60020"
echo "Autoscript Ini Daripada AsyrafAzhan"
echo "Telegram @aaron_3796"
echo "TimeZone   :  Malaysia"
echo "Vnstat     :  http://$MYIP:81/vnstat"
echo "Pritunl    :  https://$MYIP"
echo "Sila login ke pritunl untuk proceed step seterusnya"
echo "Sila copy key dibawah dan paste di Pritunl anda"
pritunl setup-key

