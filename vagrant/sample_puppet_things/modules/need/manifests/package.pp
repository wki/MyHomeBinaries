define need::package($package = $title) {
  if ! defined(Package[$package]) {
    package { $package:
      ensure => present,
    }
  }
}
