define perlbrew($user = 'vagrant', $perl_version = '5.14.2') {

  $home_dir     = "/home/$user"
  $perlbrew_dir = "$home_dir/perl5/perlbrew"
  $bin_dir      = "$perlbrew_dir/bin"
  
  $perlbrew     = "$bin_dir/perlbrew"
  $cpanm        = "$bin_dir/cpanm"
  
  ### FIXME: can we ensure user is present?

  exec { "$user-install_perlbrew":
    command => '/usr/bin/wget -q -O - http://install.perlbrew.pl | /bin/bash',
    creates => $perlbrew,
    cwd     => "/home/$user",
    # group => $user,
    user    => $user,

    require => [
      Package['wget'],
      Package ['build-essential'] 
    ],
  }

  exec { "$user-init_perlbrew":
    command => "$perlbrew init",
    creates => "$perlbrew_dir/perls",
    user    => $user,
    require => Exec["$user-install_perlbrew"],
  }

  exec { "$user-install_cpanm":
    command => "$perlbrew install-cpanm",
    creates => $cpanm,
    user    => $user,
    require => Exec["$user-init_perlbrew"],
  }

  exec { "$user-install_perl":
    command => "$perlbrew install $perl_version",
    timeout => 0,
    creates => "$perlbrew_dir/perls/perl-$perl_version/bin/perl",
    user    => $user,
    require => Exec["$user-install_perlbrew"],
  }
}

package { 'wget':
  ensure => present,
}

package { 'build-essential':
  ensure => present,
}
