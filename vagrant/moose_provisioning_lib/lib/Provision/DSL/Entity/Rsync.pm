package Provision::DSL::Entity::Rsync;
use Moose;
use Provision::DSL::Types;
use namespace::autoclean;

extends 'Provision::DSL::Entity';

has path => (
    is => 'ro',
    isa => 'PathClassDir',
    coerce => 1,
    required => 1,
    lazy_build => 1,
);
sub _build_path { $_[0]->name }

has content => (
    is => 'ro',
    isa => 'ExistingDir',
    coerce => 1,
    required => 1,
);

has exclude => (
    is => 'ro',
    isa => 'DirList',
    coerce => 1,
    default => sub { [] },
);

sub is_current {
    $_[0]->_rsync_command(
        '--dry-run',
        '--out-format' => '>>> %n',
    ) !~ m{^>>>}xms;
}

sub _rsync_command {
    my $self = shift;

    my @args = (
        '--verbose',
        '--checksum',
        '--recursive',
        '--delete',
        @_,
        ( map { $_->{path} } @{$self->exclude} ),

        "${\$self->content}/" => "${\$self->path}",
    );

    return $self->system_command('/usr/bin/rsync', @args);
}

after change => sub { $_[0]->_rsync_command };

__PACKAGE__->meta->make_immutable;
1;
