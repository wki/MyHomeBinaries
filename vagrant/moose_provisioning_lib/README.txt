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
    * name
  Provision::Entity::Package::Ubuntu  -- ubuntu specific
  Provision::Entity::Package::OSX     -- os-x specific
  Provision::Entity::Perlbrew
    * user <-- name
    * install_cpanm
    * install_perl
    * switch_to_perl
  Provision::Entity::User
    * uid
    * group
    * home_directory
  Provision::Entity::Group
    * gid
  Provision::Entity::File
    * path <-- name
    * user
    * group
    * permission
    * content => ...
  Provision::Entity::Dir
    * path <-- name
    * user
    * group
    * permission
  Provision::Entity::Tree
    * path <-- name
    * user
    * group
    * permission
    * provide => list of paths relative to path
    * remove => list of paths
  Provision::Entity::Exec
    * path <-- name
    * user
    * group
    * env
    * args


Class Hierarchiy (P = Provision, E = Entity)
=> too complicated and inflexible, use roles instead!

Provision::Entity
    Package
        OSX
        Ubuntu
    Group (gid)
        OSX
        Ubuntu
    User (uid, group)
        OSX
        Ubuntu
    Perlbrew (install_cpanm, install_perl, switch_to_perl)
    Identity (abstract :: user, group)
        Path (abstract :: path <-- name)
            Permission (abstract :: permission)
                Dir
                Tree
                File
            Exec (env, args)
        



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


