#!/bin/env bash
#System Configure
localtimzone=Kaliningrad
ssh_port=2498
created_user=serviceuser

#Install systemctl service
#nginx Web Service
install_nginx=nginx

#monit system monitoring
install_monit=monit

#Nginx configure Monit system
nginx_listen=80
nginx_servername=192.168.179.128
monit_http_port=2812

#file local time systems config
unlink /etc/localtime
ln -s /usr/share/zoneinfo/Europe/$localtimezone /etc/localtime
#Local time systems config
#update-locale LC_TIME=en_US.utf8
localectl set-locale LC_TIME=en_US.utf8
#SSH Port config /home/sshd_config
sed -i 's/#Port 22/Port $ssh_port/' /etc/ssh/sshd_config
#System Add Users
usermod -aG sudo  $created_user
echo "$created_user  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$created_user
#System user access
echo "
$created_user ALL=(ALL)NOPASSWD:/usr/bin/systemctl restart
$created_user ALL=(ALL)NOPASSWD:/usr/bin/systemctl stop
$created_user ALL=(ALL)NOPASSWD:/usr/bin/systemctl start" | tee /etc/sudoers.d/serviceuser
#Install service
apt install $install_nginx $install_monit  
#
#Configure nginx
touch /etc/nginx/conf.d/monit
echo "server {
      listen $nginx_listen;
      server_name $nginx_servername;
      access_log /var/log/nginx/access.log;
      error_log /var/log/nginx/error.log;


      location / {
      proxy_pass http://127.0.0.1:$monit_http_port;
      proxy_set_header Host \$host;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Real-IP \$remote_addr;
    }
  }" | tee /etc/nginx/conf.d/monit.conf

sed -i 's/#set set httpd port $monit_http_port and/set httpd port $monit_http_port and/' /etc/monit/monitrc
sed -i 's/#use address localhost/use address localhost/' /etc/monit/monitrc
sed -i 's/#allow localhost/allow localhost/' /etc/monit/monitrc
sed -i 's/#allow admin:monit/allow admin:monit/' /etc/monit/monitrc

systemctl start monit
systemctl start nginx

systemctl enable nginx
systemctl enable monit
