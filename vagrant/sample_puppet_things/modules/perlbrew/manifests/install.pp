class perlbrew::install($user='vagrant', $version='5.14.2') {
  exec { 'install':
    command => "/home/$user/perl5/perlbrew/bin/perlbrew install $version",
    creates => "/home/$user/perl5/perlbrew/perls/perl-$version/bin/perl",
    require => package['build-essential'],
  }
}
