package Provision::DSL::Role::CheckFileExistence;
use Moose::Role;

requries 'path', 'is_present', 'remove';

around is_present => sub {
    my ($orig, $self) = @_;
    
    return -f $self->path && $self->$orig();
};

after remove => sub { $_[0]->path->remove };

no Moose::Role;
1;
