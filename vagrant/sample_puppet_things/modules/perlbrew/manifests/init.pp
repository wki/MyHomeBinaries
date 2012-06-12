class perlbrew($user = 'vagrant') {
  
  ### FIXME: can we ensure user is present?
  
  ### FIXME: correctoy depend on wget
  
  exec { 'install':
    command => '/usr/bin/wget -q -O - http://install.perlbrew.pl | /bin/bash',
    creates => "/home/$user/perl5/perlbrew/bin/perlbrew",
    cwd => "/home/$user",
    # group => $user,
    user => $user,
    
    # require => Package['wget'],
    
    # notify { Exec[setup]: }
  }
  
  ### TODO: perlbrew-init, perlbrew-install-cpanm
  
  # exec { 'setup':
  #   command => '/bin/echo "setup would run"',
  # }
}
