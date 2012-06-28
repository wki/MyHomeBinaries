package File;
use Moose;
use MooseX::Types::Path::Class 'File';
extends 'EntityBase';

has path => (is => 'ro', isa => File, coerce => 1, lazy_build => 1);
sub _build_path { $_[0]->name }

has content => (is => 'ro', isa => 'Str', required => 1);

sub _build_state {
    my $self = shift;
    
    return 'missing'  if !-f $self->path;
    return 'outdated' if scalar $self->slurp ne $self->content;
    return 'current';
}

sub create {
    my $self = shift;
    
    my $fh = $self->path->openw;
    print $fh $self->content;
    $fh->close;
}

sub change { goto &create }

sub remove { $_->path->remove }

__PACKAGE__->meta->make_immutable;
1;
