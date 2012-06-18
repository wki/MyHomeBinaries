# = Class: timezone
#
# sets a timezone to a given location
#
# timezone { 'cet': location => 'Europe/Berlin' }

class timezone($location = 'Europe/Berlin') {
  file { '/etc/timezone':
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => "$location\n"
  }
}
