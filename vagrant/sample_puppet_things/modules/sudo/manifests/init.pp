# = Class: sudo
#
# expand sudo and ensure we have installed a prepared sudoers file
#
class sudo {
  package { 'sudo':
    ensure => installed,
  }
  service { 'sudo':
    enable => true,
    require => Package['sudo'],
    subscribe => File['sudoers'],
  }
  file { 'sudoers':
    path => '/etc/sudoers',
    owner => 'root',
    group => 'root',
    mode => '0440',
    source => 'puppet:///modules/sudo/sudoers.conf',
  }
}