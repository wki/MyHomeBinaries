package Provision::Entity::User;
use Moose;
use MooseX::Types::Path::Class 'Dir';
use namespace::autoclean;
extends 'Provision::Entity';

our $START_UID = 1000;
our $START_GID = 1000;
our $MAX_ID    = 2000;

has uid => (
    is => 'rw',
    isa => 'Int',
    required => 1,
    lazy_build => 1,
);

has gid => (
    is => 'rw',
    isa => 'Int',
    required => 1,
    lazy_build => 1,
);

has home_directory => (
    is => 'rw',
    isa => Dir,
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

sub _build_uid {
    my $self = shift;
    
    my $uid = $START_UID;
    while (++$uid < $MAX_ID) {
        next if defined getpwuid($uid);
        
        $self->log_debug("Auto-created UID: $uid");
        return $uid;
    }
    
    die 'could not create a unique UID';
}

sub _build_gid {
    my $self = shift;
    
    if (!defined getgtgid($self->uid)) {
        $self->log_debug("Auto-created GID from UID: ${\$self->uid}");
        return $self->uid;
    }
    
    my $gid = $START_GID;
    while (++$gid < $MAX_ID) {
        next if defined getgrgid($gid);

        $self->log_debug("Auto-created GID: $gid");
        return $gid;
    }
    
    die 'could not create a unique GID';
}

sub is_present {
    my $self = shift;
    
    return getpwnam($self->name);
}

__PACKAGE__->meta->make_immutable;
1;
