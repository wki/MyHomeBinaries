#!/bin/bash
#
# initially setup a new Ubuntu box
# must run as user 'root'
#

echo "Setting Time Zone..."
echo "Europe/Berlin" > /etc/timezone
cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo "removing motd..."
/usr/bin/perl -pi -e 's/^([^#].*motd.*)$/#$1/' /etc/pam.d/*
echo "Box: Welcome" > /etc/motd

echo "installing some packages..."
apt-get -y install nginx-full \
                   postgresql-9.1 postgresql-client-9.1 libpq5 libpq-dev \
                   redis-server \
                   libgif-dev libgif4 libjpeg8 libjpeg8-dev \
                   libpng12-0 libpng12-dev \
                   libxml2 libxml2-dev \
                   curl

echo "changing PostgreSQL config"
/usr/bin/perl -pi -e 's/^([^#].+)$/# $1/' /etc/postgresql/9.1/main/pg_hba.conf
echo "local all all trust" >> /etc/postgresql/9.1/main/pg_hba.conf
echo "host all all 127.0.0.1/32 trust" >> /etc/postgresql/9.1/main/pg_hba.conf
echo "host all all ::1/128 trust" >> /etc/postgresql/9.1/main/pg_hba.conf
service postgresql reload

echo "enabling sudo for every admin and sudo group users"
# fixme: too dangerous?
/usr/bin/perl -pi -e 's/^%(admin|sudo).*$/%$1 ALL=NOPASSWD: ALL/' -i /etc/sudoers
service sudo restart

echo "creating user 'sites'"
useradd sites -m

echo "installing ssh keys"
mkdir ~/.ssh
curl -Ls http://github.com/mitchellh/vagrant/raw/master/keys/vagrant > ~/.ssh/vagrant
curl -Ls http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub > ~/.ssh/vagrant.pub
cp ~/.ssh/vagrant.pub ~/.ssh/authorized_keys
chmod 600 ~/.ssh/*

for user in vagrant sites; do
    cp -r ~/.ssh /home/$user/
    chown -R $user:$user /home/$user/.ssh
done
