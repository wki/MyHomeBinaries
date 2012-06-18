# a simple puppet manifest for testing
# test with:
#  $ puppet apply --modulepath=./modules installme.pp
#
# or:
#  $ rsync -vcr sample_puppet_things box:
#  $ ssh box 'cd sample_puppet_things; sudo puppet apply --modulepath=modules installme.pp'
#
# syntaxcheck: add --noop option
#
node default {
  class { 'sudo': }
  class { 'timezone': }
  class { 'motd': }
  class { 'nginx': }
  
  perlbrew { 'perlbrew_vagrant':
    user         => 'vagrant',
    perl_version => '5.16.0',
  }
}
