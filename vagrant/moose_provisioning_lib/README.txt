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
  Provision::Entity::User
  Provision::Entity::File
  Provision::Entity::Dir
  Provision::Entity::Tree


structure of files for applying:

/
  bin/
    apply.pl
  lib/
    ... all perl modules needed
  files/
    ... all files needed


order:
 - pack everything into a .tar.gz
 - copy .tar.gz to /tmp
 - unpack .tar.gz
 - PERL5LIB=/tmp/lib perl /tmp/bin/apply.pl [options]
 - done.


