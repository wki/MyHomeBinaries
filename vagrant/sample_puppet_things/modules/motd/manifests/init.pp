class motd {
  file { 'motd':
    path => '/etc/motd',
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => 'Welcome to the box',
  }
  
  # if motd is entirely unwanted:
  
  # exec { '/usr/bin/perl -pi -e \'s/^([^#].*motd.*)$/#$1/\' /etc/pam.d/*':
  #   onlyif => '/bin/grep -E \'^\s*[^#].*motd\' /etc/pam.d/*',
  # }
}