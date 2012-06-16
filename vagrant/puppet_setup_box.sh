#!/bin/bash
#
# initially setup a new Ubuntu box for use with puppet
# must run as user 'root' immediately after a fresh OS install
# only urgently needed things are set up, everything else is done by puppet
#
apt-get install puppet

# modify /etc/sudoers -- or apply a puppet manifest?

### for the server environment have manifests for
###
###  - user 'sites', fixed uid, maybe: vagrant ssh keys
###
###  - postgresql   -- server + config
###    https://github.com/camptocamp/puppet-postgresql
###
###  - nginx        -- server + base config
###    https://github.com/example42/puppet-nginx
###    https://github.com/BenoitCattie/puppet-nginx
###
###  - perlbrew as user 'sites'
###    https://github.com/rafl/puppet-module-perlbrew
###
###  - project (git clone or via rsync ???)
###
###  - dependencies (perl modules, debian packages)
###
###  - additions to nginx config
###
###  - db schema (initial or upgrade)
###
###  - create missing directories, permissions, static files
###
###  - run deployment tests
###
###  - (re)start daemons
