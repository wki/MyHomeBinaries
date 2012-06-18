# = Class: nginx
#
# ensures package nginx is installed
#
# TODO: add site support etc.
#
class nginx {
  package { 'nginx':
    name => 'nginx-full',
    ensure => installed,
  }
  service { 'nginx':
    ensure => running,
    enable => true,
    require => Package['nginx'],
    subscribe => File['nginx_config'],
  }
  
  file { 'nginx_config':
    path => '/etc/nginx/nginx.conf',
  }
}
