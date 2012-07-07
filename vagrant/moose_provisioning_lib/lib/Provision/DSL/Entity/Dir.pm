package Provision::DSL::Entity::Dir;
use Moose;
use Provision::DSL::Types;

extends 'Provision::DSL::Entity::Compound';
sub path; # must forward-declare
with 'Provision::DSL::Role::CheckDirExistence',
     'Provision::DSL::Role::PathPermission',
     'Provision::DSL::Role::PathOwner';

sub _build_permission { '0755' }

has path => (
    is => 'ro',
    isa => 'PathClassDir',
    coerce => 1,
    lazy_build => 1,
);
sub _build_path { $_[0]->name }

has [qw(mkdir rmdir)] => (
    is => 'rw',
    isa => 'DirList',
    coerce => 1,
    default => sub { [] },
);

has content => (
    is => 'ro', 
    isa => 'ExistingDir', 
    coerce => 1, 
    predicate => 'has_content',
);

sub _build_children {
    my $self = shift;

    return [
        $self->__as_entities($self->mkdir, 1),
        $self->__as_entities($self->rmdir, 0),
        
        ($self->has_content
            ? $self->entity(Rsync => {
                    parent => $self,
                    name   => $self->name,
                    content => $self->content,
                    exclude => $self->mkdir,
                })
            : () ),
    ];
}

sub __as_entities {
    my ($self, $directories, $wanted) = @_;

    map {
        $self->entity(
            Dir => {
                parent => $self,
                name   => $_,
                path   => $self->path->subdir($_),
                wanted => $wanted,
            })
    }
    @$directories
}

__PACKAGE__->meta->make_immutable;
1;
