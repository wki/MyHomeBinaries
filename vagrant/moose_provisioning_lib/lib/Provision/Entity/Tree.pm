package Provision::Entity::Tree;
use Moose;
use MooseX::Types::Path::Class 'Dir';
use Path::Class;
use namespace::autoclean;
use Provision::Types;

extends 'Provision::Entity';
with 'Provision::Role::User';
with 'Provision::Role::Group';
with 'Provision::Role::Permission';

sub _build_permission { '755' }

has base_dir => (
    is => 'ro',
    isa => Dir,
    required => 1,
    lazy_build => 1,
);

sub _build_base_dir { dir('/') }

has provide => (
    is => 'ro',
    isa => 'DirList',
    default => sub { [] },
);

has remove => (
    is => 'ro',
    isa => 'DirList',
    default => sub { [] },
);

sub is_present {
    my $self = shift;
    
    return if !_path_is_ok($self->base_dir);
           || grep { -d $_->{path} } @{$self->remove};
           || grep { !$_->_path_is_ok($_) } @{$self->create};
    
    return 1;
}

sub _path_is_ok {
    my ($self, $path_or_structure) = @_;
    
    ### FIXME: totally ugly.
    
    my ($uid, $gid, $permission, $path);
    if (ref $path_or_structure eq 'HASH') {
        $path = $path_or_structure->{path};
        $uid  = $path_or_structure->{uid};
        $gid  = $path_or_structure->{gid};
    } else {
        $path = $path_or_structure;
    }
    
    $uid //= $self->user->uid;
    $gid //= $self->group->gid;
    $permission //= $self->permission;

    my $path = ref $path_or_structure eq 'HASH'
        ? $path_or_structure->{path}
        : $path;
    
    
    return if !-d $path;
    return if !$self->_path_has_requested_permission($path_or_structure);
    return if !$self->_path_has_requested_owner($path_or_structure);
    
}

sub _path_has_requested_permission {
    
}

sub _path_has_requested_owner {
    
}

sub create {
    my $self = shift;
    
    
}

__PACKAGE__->meta->make_immutable;
1;
