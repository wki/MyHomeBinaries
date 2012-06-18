# = Class: motd
#
# modify ubuntu's extremly verbose motd nehavior by replacing the motd
# with a simple "Welcome to the box" message
#
# setting quiet to true completely disables motd generation
#
class motd ($quiet = false) {
  file { 'motd':
    path => '/etc/motd',
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => 'Welcome to the box',
  }
  
  if $quiet {
    exec { '/usr/bin/perl -pi -e \'s/^([^#].*motd.*)$/#$1/\' /etc/pam.d/*':
      onlyif => '/bin/grep -E \'^\s*[^#].*motd\' /etc/pam.d/*',
    }
  }
}
