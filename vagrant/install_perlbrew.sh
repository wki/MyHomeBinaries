#!/bin/bash
#
# install perlbrew and some essential tools
# runs as user 'vagrant'

echo "install perlbrew..."
curl -skL http://install.perlbrew.pl | bash

echo "" >> ~/.profile
echo "# initiate perlbrew" >> ~/.profile
echo ". ~/perl5/perlbrew/etc/bashrc" >> ~/.profile

. ~/perl5/perlbrew/etc/bashrc
perlbrew install-cpanm

echo "build perl-5.14.2..."
perlbrew install perl-5.14.2
perlbrew switch perl-5.14.2

echo "installing carton..."
cpanm carton

