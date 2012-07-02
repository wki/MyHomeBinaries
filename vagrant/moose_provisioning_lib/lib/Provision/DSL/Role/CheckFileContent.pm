package Provision::DSL::Role::CheckFileContent;
use Moose::Role;

requires 'path', 'content', 'is_current', 'create', 'change';

around is_current => sub {
    my ($orig, $self) = @_;
    
    return scalar $self->path->slurp eq $self->content && $self->$orig();
};

after ['create', 'change'] => sub {
    my $self = shift;
    
    my $fh = $self->path->openw;
    print $fh $self->content;
    $fh->close;
};

no Moose::Role;
1;
