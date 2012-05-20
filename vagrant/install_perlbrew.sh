#!/bin/bash
#
# install perlbrew and some essential tools
# runs as user 'sites'

echo "install perlbrew..."
curl -skL http://install.perlbrew.pl | bash

echo "" >> ~/.profile
echo "# initiate perlbrew" >> ~/.profile
echo ". ~/perl5/perlbrew/etc/bashrc" >> ~/.profile

. ~/perl5/perlbrew/etc/bashrc
perlbrew install-cpanm

echo "build perl-5.14.2..."
# uname -i ???
# 32 bit: -Dplibpth=/usr/lib/i386-linux-gnu
# 64 bit: -Dplibpth=/usr/lib/x86_64-linux-gnu
perlbrew install perl-5.14.2 -Dplibpth=/usr/lib/i386-linux-gnu
perlbrew switch perl-5.14.2

echo "installing carton..."
cpanm carton

