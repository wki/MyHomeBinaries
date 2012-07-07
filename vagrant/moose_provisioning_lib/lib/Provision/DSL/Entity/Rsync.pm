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
        '--out-format' => 'copying %n',
    ) !~ m{^(?:deleting|copying)\s}xms;
}

sub _rsync_command {
    my $self = shift;

    my @args = (
        '--verbose',
        '--checksum',
        '--recursive',
        '--delete',
        @_,
        $self->_exclude_list,
        "${\$self->content}/" => "${\$self->path}",
    );

    return $self->system_command('/usr/bin/rsync', @args);
}

# rsync reports to delete a directory if its subdirectory is in exclusion
# thus, we have to resolve every path to every of its parents
sub _exclude_list {
    my $self = shift;

    my @exclude_list;
    foreach my $exclude (@{$self->exclude}) {
        my $path = $exclude->{path};
        $path =~ s{\A / | / \z}{}xmsg;

        my @parts = split '/', $path;
        push @exclude_list, '--exclude', join('/', @parts[0..$_])
            for (0..$#parts);
    }

    return @exclude_list;
}

after change => sub { $_[0]->_rsync_command };

__PACKAGE__->meta->make_immutable;
1;
