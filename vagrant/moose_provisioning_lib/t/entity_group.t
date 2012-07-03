use Test::More;
use Test::Exception;
use Path::Class;

use ok 'Provision::DSL';

my $current_group = getgrgid($();

can_ok 'main', 'Group';

# basic behavior
{
    my $g;
    
    
    undef $g;
    dies_ok { $g = Group() }
            'creating an unnamed group entity dies';
    
    
    undef $g;
    lives_ok { $g = Group('frodo_strange_hopefully') }
             'creating a named but unknown group entity lives';
    isa_ok $g, 'Provision::DSL::Entity::Group';
    ok !$g->is_present, 'an unknown group is not present';
    
    
    undef $g;
    lives_ok { $g = Group($current_group) }
             'creating a named and known group entity lives';
    isa_ok $g, 'Provision::DSL::Entity::Group';
    ok $g->is_present, 'a known group is present';
}

# creating and removing a group (requires root privileges)
SKIP: {
    skip 'root privileges required for creating groups',7 if $<;
    
    my $unused_gid = find_unused_gid();
    my $unused_group = find_unused_group();

    my $g = Group($unused_group, {gid => $unused_gid});
    ok !$g->is_present, "unused group '$unused_group' ($unused_gid) not present";
    
    lives_ok { $g->process(1) } 'creating a new group lives';
    ok $g->is_present, "former unused group '$unused_group' ($unused_gid) present";
    is getgrnam($unused_group), $unused_gid, 'group really present';
    
    lives_ok { $g->process(1) } 'creating a new group lives';
    ok !$g->is_present, "group '$unused_group' ($unused_gid) removed";
    ok !getgrnam($unused_group), 'group really removed';
}


done_testing;

sub find_unused_gid {
    for my $gid (1000 .. 2000) {
        getgrgid($gid) and return $gid;
    }
    
    die 'could not find a free gid, stopping';
}

sub find_unused_group {
    for my $name ('aa' .. 'zz') {
        getgrnam("group$name") and return "group$name";
    }

    die 'could not find a free group name, stopping';
}
