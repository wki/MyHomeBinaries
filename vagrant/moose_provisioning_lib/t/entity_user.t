use Test::More;
use Test::Exception;
use Path::Class;

use ok 'Provision::DSL';

my $current_user = getpwuid($<);

can_ok 'main', 'User';

my $u;


undef $u;
dies_ok { $u = User() }
        'creating an unnamed user entity dies';


undef $u;
lives_ok { $u = User('frodo_unknown_hopefully') }
         'creating a named but unknown user entity lives';
isa_ok $u, 'Provision::DSL::Entity::User';
ok !$u->is_present, 'an unknown user is not present';


undef $u;
lives_ok { $u = User($current_user) }
         'creating a named and known user entity lives';
isa_ok $u, 'Provision::DSL::Entity::User';
ok $u->is_present, 'a known user is present';
isa_ok $u->home_directory, 'Path::Class::Dir';
ok -d $u->home_directory, 'home directory exists';
is $u->home_directory->absolute->resolve->stringify,
   dir($ENV{HOME})->absolute->resolve->stringify,
   'home directory eq $ENV{HOME}';
isa_ok $u->group, 'Provision::DSL::Entity::Group';


done_testing;
