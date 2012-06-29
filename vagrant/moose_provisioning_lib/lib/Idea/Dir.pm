package Dir;
use Moose;
use MooseX::Types::Path::Class 'Dir';
extends 'EntityBase';

has path => (is => 'ro', isa => Dir, coerce => 1, lazy_build => 1);
sub _build_path { $_[0]->name }

augment is_present => sub { -d $_[0]->path };
augment is_current => sub { 1 };

sub create {
    my $self = shift;
    
    my $fh = $self->path->openw;
    print $fh $self->content;
    $fh->close;
}

sub remove { $_->path->remove } ### TODO: must recurse!

__PACKAGE__->meta->make_immutable;
1;
