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
    * name
  Provision::Entity::Package
  Provision::Entity::Package::Ubuntu  -- ubuntu specific
  Provision::Entity::Package::OSX     -- os-x specific
  Provision::Entity::Perlbrew
    * user
    * install_cpanm
    * install_perl
    * switch_to_perl
  Provision::Entity::User
    * uid
    * gid
    * home_directory
  Provision::Entity::File
    * user
    * group
    * permission
    * path
    * content => ...
  Provision::Entity::Tree
    * user
    * group
    * permission
    * provide => list of paths
    * remove => list of paths
  Provision::Entity::Exec
    * user
    * group
    * env
    * path
    * args

structure of files for applying (packed into a .tar.gz):

/
  apply.pl                  -- default provision file
  bin/
    cpanm
    perlbrew
  etc/
    dependencies.txt        -- all needed CPAN modules
    ... more config files
  lib/
    ... provision modules
  local/
    ... cpanm installed, empty in .tar.gz
  resources/
    ... all files needed


structure in the root of a project as a cache:

.provision/
  bin/
    cpanm           -- cached versions, mirror-checked if older 1 day
    perlbrew
  (everything else gets directly into .tar.gz)


order:
 - provision_prepare.pl \
        --provision xxx.pl \
        --resource relative_dir=/path/to/whatever \
        --resource another_dir=/path/to/something_else \
        --save_to xxx.tar.gz
 - scp xxx.tar.gz server:/whatever
 - unpack .tar.gz to /root/provision/
 - /path/to/perl /root/provision/apply.pl
 - done.


