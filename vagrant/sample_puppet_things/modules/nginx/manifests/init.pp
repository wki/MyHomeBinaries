class nginx {
  package { 'nginx':
    name => 'nginx-full',
    ensure => installed,
  }
  service { 'nginx':
    ensure => running,
    enable => true,
    require => Package['nginx'],
  }
}
