class perlbrew($user = 'vagrant') {

  ### FIXME: can we ensure user is present?

  exec { 'install_perlbrew':
    command => '/usr/bin/wget -q -O - http://install.perlbrew.pl | /bin/bash',
    creates => "/home/$user/perl5/perlbrew/bin/perlbrew",
    cwd => "/home/$user",
    # group => $user,
    user => $user,

    require => [
      Package['wget'],
      Package ['build-essential'] 
    ],
  }

  exec { 'init_perlbrew':
    command => "/home/$user/perl5/perlbrew/bin/perlbrew init",
    creates => "/home/$user/perl5/perlbrew/perls",
    require => Exec['install_perlbrew'],
  }

  exec { 'install_cpanm':
    command => "/home/$user/perl5/perlbrew/bin/perlbrew install-cpanm",
    creates => "/home/$user/perl5/perlbrew/bin/cpanm",
    require => Exec['init_perlbrew'],
  }

  package { 'wget':
    ensure => present,
  }

  package { 'build-essential':
    ensure => present,
  }
}
