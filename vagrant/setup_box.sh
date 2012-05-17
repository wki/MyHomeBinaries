#!/bin/bash
#
# initially setup a new Ubuntu box
# must run as root
#

echo "Setting Time Zone..."
echo "Europe/Berlin" > /etc/timezone
cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo "removing motd..."
/usr/bin/perl -pi -e 's/^([^#].*motd.*)$/#$1/' /etc/pam.d/*
echo "Vagrant Box: Welcome" > /etc/motd

echo "installing some daemons..."
apt-get -y install nginx-full postgresql-9.1 postgresql-client-9.1 redis-server \
                   libgif-dev libgif4 libjpeg8 libjpeg8-dev \
                   libpng12-0 libpng12-dev \
                   libxml2 libxml2-dev \
                   curl

echo "manipulating pg_hba.conf"
echo "local all all trust" >> /etc/postgresql/9.1/main/pg_hba.conf
echo "host all all 127.0.0.1/32 trust" >> /etc/postgresql/9.1/main/pg_hba.conf
echo "host all all ::1/128 trust" >> /etc/postgresql/9.1/main/pg_hba.conf

echo "enabling sudo for every admin"
sed -s 's/^\(%admin.*\)$/# OFF: # \1\n%admin ALL=NOPASSWD: ALL/' -i .bak /etc/sudoers
service sudo restart

