# = Define: catalyst
#
# install a catalyst website with all dependencies
#
class catalyst($user = 'vagrant', $group = 'vagrant', $root_dir) {
  need::user { $user: }
  
  file { "$root_dir":
    ensure => directory,
    owner => $user,
    group => $group,
    mode => 0755
  }
  
  # prepare directories -- according to file/list ???
  
  # rsync to directories -- exclude list ???
  
  # cpanm --installdeps .
  
  # create/upgrade database
  
  # run smoke tests
  
  # prepare cachable static data (eg CSS/JS)
  
  # ensure server-starter is running
  
  # ensure nginx config is properly setup
  
  # perlbrew { 'perlbrew_vagrant':
  #   user         => $user,
  #   perl_version => $perl_version,
  # }
  
  
}
