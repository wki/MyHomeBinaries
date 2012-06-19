Alternative to puppet
---------------------


Library + DSL -> script -> copy to server -> run

Example:
    #!/usr/bin/env perl
    use Provision;
    
    Pack 'wget';
    Pack 'build-essential';
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
  