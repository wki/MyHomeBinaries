# a simple puppet manifest for testing
# test with:
#  $ puppet apply --modulepath=./modules installme.pp
#
# or:
#  $ rsync -vcr sample_puppet_things box:
#  $ ssh box 'cd sample_puppet_things; sudo puppet apply --modulepath=modules installme.pp'
#
node default {
  class { 'sudo': }
  class { 'timezone': }
  class { 'motd': }
  class { 'nginx': }
  class { 'perlbrew': }
  class { 'perlbrew::install': 
    version => '5.14.2'
  }

}