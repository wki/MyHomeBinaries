package Provision::DSL::Role::CheckDirExistence;
use Moose::Role;

requires 'path', 'is_present', 'remove';

around is_present => sub {
    my ($orig, $self) = @_;
    
    return -d $self->path && $self->$orig();
};

after ['create', 'change'] => sub { $_[0]->path->mkpath };

after remove => sub { $_[0]->path->remove }; ### TODO: recursive

no Moose::Role;
1;
