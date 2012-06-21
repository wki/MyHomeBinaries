Alternative to puppet
---------------------


Library + DSL -> script -> copy to server -> run

Example:
    #!/usr/bin/env perl
    use Provision;
    
    Package 'wget';
    Package 'build-essential';
    User 'vagrant', 
        uid => 501, 
        gid => 501, 
        groups => [qw(staff admin)];
    File '/etc/sodoers',
        content => ...;


Provision           -- enthält Befehlsworte pro package
  Provision::Entity -- Basisklasse
  Provision::Entity::Package
  Provision::Entity::Package::Ubuntu  -- ubuntu specific
  Provision::Entity::Package::OSX     -- os-x specific
  Provision::Entity::User
  Provision::Entity::File
  Provision::Entity::Dir
  Provision::Entity::Tree


structure of files for applying:

/
  Makefile.PL
  bin/
    apply.pl
  lib/
    ... all perl modules needed
  local/
    ... cpanm provided stuff
  files/
    ... all files needed


order:
 - pack everything into a .tar.gz
 - copy .tar.gz to /root/provision
 - unpack .tar.gz
 - PERL5LIB=/root/provision/lib:/root/provision/local/lib/perl5 \
   perl /root/provision/bin/apply.pl [options]
 - done.


