class perlbrew($user = 'vagrant') {

  $home_dir     = "/home/$user"
  $perlbrew_dir = "$home_dir/perl5/perlbrew"
  $bin_dir      = "$perlbrew_dir/bin"
  
  $perlbrew     = "$bin_dir/perlbrew"
  $cpanm        = "$bin_dir/cpanm"
  
  ### FIXME: can we ensure user is present?

  exec { 'install_perlbrew':
    command => '/usr/bin/wget -q -O - http://install.perlbrew.pl | /bin/bash',
    creates => $perlbrew,
    cwd => "/home/$user",
    # group => $user,
    user => $user,

    require => [
      Package['wget'],
      Package ['build-essential'] 
    ],
  }

  exec { 'init_perlbrew':
    command => "$perlbrew init",
    creates => "$perlbrew_dir/perls",
    require => Exec['install_perlbrew'],
  }

  exec { 'install_cpanm':
    command => "$perlbrew install-cpanm",
    creates => $cpanm,
    require => Exec['init_perlbrew'],
  }

  package { 'wget':
    ensure => present,
  }

  package { 'build-essential':
    ensure => present,
  }
}
