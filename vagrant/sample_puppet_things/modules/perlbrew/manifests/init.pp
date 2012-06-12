class perlbrew($user = 'vagrant') {
  
  ### FIXME: can we ensure user is present?
  
  exec { 'wget':
    command => '/usr/bin/wget -q -O - http://install.perlbrew.pl | /bin/bash',
    creates => "/home/$user/perl5/perlbrew/bin/perlbrew",
    cwd => "/home/$user",
    # group => $user,
    user => $user,
    
    # notify { Exec[setup]: }
  }
  
  # exec { 'setup':
  #   command => '/bin/echo "setup would run"',
  # }
}
