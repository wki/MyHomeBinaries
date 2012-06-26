package Provision::Entity::Group;
use Moose;
use namespace::autoclean;

extends 'Provision::Entity';

our $START_GID = 1000;
our $MAX_ID    = 2000;

has gid => (
    is => 'ro',
    isa => 'Int',
    required => 1,
    lazy_build => 1,
);

sub _build_gid {
    my $self = shift;
    
    my $gid = (getpwnam($self->name))[3];
    return $gid if $gid;
    
    $gid = $START_GID;
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
