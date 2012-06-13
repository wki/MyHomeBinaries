class perlbrew::install($version='5.14.2') {
  
  exec { 'install_perl':
    command => "$perlbrew::perlbrew install $version",
    timeout => 0,
    creates => "$perlbrew::perlbrew_dir/perls/perl-$version/bin/perl",
    require => Exec['install_perlbrew'],
  }
}
