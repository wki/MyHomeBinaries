#
# = Define: user_account
#
# ensures a given user account is present on a system.
#
# == Synopsis:
#
# user_account { 'user_name': }
#
#    is equivalent to:
#
# user_name { 'user_name':
#   username  => 'user_name',
#   groupname => 'user_name',
# }
#
# stolen from https://github.com/blt04/puppet-rvm/blob/master/manifests/system_user.pp
#

define user_account($username = $title, $groupname = $title) {

  if ! defined(User[$username]) {
    user { $username:
      ensure => present,
    }
  }

  if ! defined(Group[$groupname]) {
    group { $groupname:
      ensure => present,
    }
  }

  exec { "/usr/sbin/usermod -a -G $groupname $username":
    unless  => "/bin/cat /etc/group | grep $groupname | grep $username",
    require => [User[$username], Group[$group]];
  }
}
