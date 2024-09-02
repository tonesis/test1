#! /bin/env bash

apt-get install wget -y
echo "task 01"
echo "Переменные скрипта"
# Регион 
region=Europe
#Город
sity=Moscow

#Порт OpenSSH
port_system=22

#Системный пользователь sudo
system_user=serviceuser
ssh_user_auth=root

# nginx, monit 
package_install_web=nginx
package_install_monitoring=monit



###################################
echo "time_zone"
ln -sf /usr/share/zoneinfo/$region/$sity /etc/localtime
echo "time-zone correct"
###################################
echo "settings locale"
timedatectl set-timezone Europe/Moscow
echo "locale setting done"
##################################
echo "ssh port configure systems"
sed -i "s/#Port.*/Port $port_system/g" /etc/ssh/sshd_config
echo "sshd configure  is done"
echo "restart ssh service"
systemctl restart ssh
echo "restart is done"
##################################
echo "system perm root"
sed -i "/s/PermitRootLogin $ssh_user_auth/PermitRootLogin/g" /etc/ssh/ssh_config
echo "user configure is done"
##################################
echo "add system user"
adduser $system_user
usermod -aG sudo $system_user
echo "configure user is done"
#################################
echo "limit serviceuser  sudo operation"
echo "$system_user  ALL=NOPASSWD:/bin/systemctl" >> /etc/sudoers
echo "access user is done"
################################
echo "apt install nginx"
apt update -y && apt install $package_install_web
echo "apt install monit"
apt install $package_install_monitoring
echo "install software is done"
################################
echo "ufw configure"
ufw enable
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 2812/tcp
ufw allow 22/tcp

echo "start service"
systemctl enable monit && systemctl start monit
systemctl enable nginx && systemctl start nginx
echo "done service start"
echo "configure nginx/monit"
cd /etc/nginx/conf.d/ && wget  -o monit.conf https://raw.githubusercontent.com/tonesis/test1/main/config/monit.conf
cd /etc/monit/ && wget -o monitrc https://raw.githubusercontent.com/tonesis/test1/main/config/monitrc
echo "restart vm"
shutdown -r now
