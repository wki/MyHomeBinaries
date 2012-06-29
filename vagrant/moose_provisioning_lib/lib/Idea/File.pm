package File;
use Moose;
use MooseX::Types::Path::Class 'File';
extends 'EntityBase';

has path => (is => 'ro', isa => File, coerce => 1, lazy_build => 1);
sub _build_path { $_[0]->name }

### IDEA: s/Str/FileContent/, coerce => 1 in order to read url, ...
has content => (is => 'ro', isa => 'ResourceContent', coerce => 1, required => 1);

augment is_present => sub { -f $_[0]->path };
augment is_current => sub { scalar $_[0]->path->slurp ne $_[0]->content };

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
