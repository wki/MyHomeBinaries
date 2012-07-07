package Provision::DSL::Role::CheckDirExistence;
use Moose::Role;

requires 'path', 'is_present', 'remove';

around is_present => sub {
    my ($orig, $self) = @_;

    return -d $self->path && $self->$orig();
};

after ['create', 'change'] => sub { $_[0]->path->mkpath };

after remove => sub {
    my $self = shift;

    $self->path->traverse(\&_remove_recursive) if -d $self->path;
};

sub _remove_recursive {
    my ($child, $cont) = @_;
            
    $cont->() if -d $child;
    $child->remove;
}

no Moose::Role;
1;
