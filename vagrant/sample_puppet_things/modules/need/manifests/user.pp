define need::user($username = $title, $groupname = $title) {
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
    require => [
      User[$username],
      Group[$groupname]
    ];
  }
}
