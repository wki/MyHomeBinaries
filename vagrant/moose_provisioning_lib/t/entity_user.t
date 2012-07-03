use Test::More;
use Test::Exception;
use Path::Class;

use ok 'Provision::DSL';

my $current_user = getpwuid($<);

can_ok 'main', 'User';

# basic behavior
{
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
    # fails for root when started via sudo
    # is $u->home_directory->absolute->resolve->stringify,
    #    dir($ENV{HOME})->absolute->resolve->stringify,
    #    'home directory eq $ENV{HOME}';
    isa_ok $u->group, 'Provision::DSL::Entity::Group';
}

# creating and removing a user (requires root privileges)
SKIP: {
    skip 'root privileges required for creating users', 7 if $<;
    
    my $unused_uid  = find_unused_uid();
    my $unused_user = find_unused_user();
    my $group       = find_a_group();
    
    # warn "USING GROUP: $group";
    # my $g = Group($group);

    my $u = User($unused_user, {uid => $unused_uid, group => $group});
    ok !$u->is_present, "unused user '$unused_user' ($unused_uid) not present";
    
    lives_ok { $u->process(1) } 'creating a new user lives';
    ok $u->is_present, "former unused user '$unused_user' ($unused_uid) present";
    is getpwnam($unused_user), $unused_uid, 'user really present';
    
    lives_ok { $u->process(0) } 'removing an existing user lives';
    
    ### strange: these 2 fail, but remove really works.
    ok !$u->is_present, "user '$unused_user' ($unused_uid) removed";
    ok !getpwnam($unused_user), 'user really removed';
}


done_testing;


sub find_a_group {
    for my $gid (1 .. 1000) {
        my $name = getgrgid($gid);
        return $name if defined $name;
    }
    
    die 'could not find a group';
}

sub find_unused_uid {
    for my $uid (1000 .. 2000) {
        getpwuid($uid) or return $uid;
    }
    
    die 'could not find a free uid, stopping';
}

sub find_unused_user {
    for my $name ('aa' .. 'zz') {
        getpwnam("user$name") or return "user$name";
    }

    die 'could not find a free user name, stopping';
}

