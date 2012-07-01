package Provision::DSL::Entity::User;
use Moose;
use namespace::autoclean;

extends 'Provision::DSL::Entity';
# with 'Provision::Role::Group';

### FIXME: how do we ensure group existence?

our $START_UID = 1000;
our $MAX_ID    = 2000;

has uid => (
    is => 'ro',
    isa => 'Int',
    required => 1,
    lazy_build => 1,
);

has home_directory => (
    is => 'ro',
    isa => Dir,
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

has group => (
    is => 'ro',
    isa => 'Group',
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

sub _build_uid {
    my $self = shift;
    
    my $uid = (getpwnam($self->name))[2];
    return $uid if $uid;
    
    $uid = $START_UID;
    while (++$uid < $MAX_ID) {
        next if defined getpwuid($uid);
        
        $self->log_debug("Auto-created UID: $uid");
        return $uid;
    }
    
    die 'could not create a unique UID';
}

sub _build_group {
    my $self = shift;
    
    # if user exists: look up his group
    # assume group with same name
}

around is_present => sub {
    my ($orig, $self) = @_;
    
    return getpwnam($self->name) && $self->$orig();
};

before create => sub {
    my $self = shift;

    $self->log_dryrun("would create User home_directory '${\$self->home_directory}'")
        and return;

    $self->home_directory->mkpath;
    chown $self->uid, $self->group->gid, $self->home_directory;
};

__PACKAGE__->meta->make_immutable;
1;
