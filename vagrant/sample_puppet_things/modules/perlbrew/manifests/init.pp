# = Define: perlbrew
#
# ensures that perlbrew and a given perl version exists under a given
# user account.
#
# perlbrew { 'perlbrew': user => 'user_name', perl_version => '5.16.0' }
#
# TODO: creates a class "perlbrew_$user"
#
class perlbrew($user = 'vagrant', $perl_version = '5.14.2') {
  $home_dir     = "/home/$user"
  $perlbrew_dir = "$home_dir/perl5/perlbrew"
  $bin_dir      = "$perlbrew_dir/bin"
  
  $perlbrew     = "$bin_dir/perlbrew"
  $cpanm        = "$bin_dir/cpanm"
  $perl         = "$perlbrew_dir/perls/perl-$perl_version/bin/perl"
  
  need::user    { 'vagrant': }
  need::package { 'wget': }
  need::package { 'build-essential': }
  
  
  exec { 'install_perlbrew':
    command => '/usr/bin/wget -q -O - http://install.perlbrew.pl | /bin/bash',
    creates => $perlbrew,
    cwd     => "/home/$user",
    group   => $user,
    user    => $user,
  
    require => [
      User[$user],
      Package['wget'],
      Package['build-essential'],
    ],
  }
  
  exec { 'init_perlbrew':
    command => "$perlbrew init",
    creates => "$perlbrew_dir/perls",
    user    => $user,
    require => Exec['install_perlbrew'],
  }
  
  exec { 'install_cpanm':
    command => "$perlbrew install-cpanm",
    creates => $cpanm,
    user    => $user,
    require => Exec['init_perlbrew'],
  }
  
  exec { 'install_perl':
    command => "$perlbrew install $perl_version",
    timeout => 0,
    creates => $perl,
    user    => $user,
    require => Exec['init_perlbrew'],
  }
}
