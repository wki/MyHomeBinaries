# stolen from https://github.com/blt04/puppet-rvm/blob/master/manifests/system_user.pp
define perlbrew::user () {

  $username = $title
  $group = $::operatingsystem ? {
    default => 'rvm',
  }

  if ! defined(User[$username]) {
    user { $username:
      ensure => present;
    }
  }

  if ! defined(Group[$group]) {
    group { $group:
      ensure => present;
    }
  }

  exec { "/usr/sbin/usermod -a -G $group $username":
    unless  => "/bin/cat /etc/group | grep $group | grep $username",
    require => [User[$username], Group[$group]];
  }
}