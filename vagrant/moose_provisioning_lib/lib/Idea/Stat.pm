package Permission;
use Moose;
use Path::Class;
extends 'EntityBase';

has path => (is => 'ro', isa => 'Object', lazy_build => 1);
sub _build_path {
    my $self = shift;
    my $path = $self->name;

    return -d $path
        ? dir($path)
        : file($path)
}

has permission => (is => 'ro', isa => 'Int');

sub _build_state {
    my $self = shift;
    
    my $stat = $self->path->stat
        or return 'missing';
    
    return ($stat & 255) == $self->permission
        ? 'current'
        : 'outdated';
}

sub create { }

sub change { 
    my $self = shift; 
    chmod $self->permission, $self->path;
}

sub remove { }

__PACKAGE__->meta->make_immutable;
1;
