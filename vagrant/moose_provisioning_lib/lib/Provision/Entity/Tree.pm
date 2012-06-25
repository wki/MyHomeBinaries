package Provision::Entity::Tree;
use Moose;
use namespace::autoclean;
use Provision::Types 'UserEntity';

extends 'Provision::Entity';

has user => (
    is => 'rw',
    isa => UserEntity,
    required => 1,
    coerce => 1,
);

has group => (
    is => 'rw',
    isa => 'Str', # TODO: GroupEntity,
    required => 1,
    # coerce => 1,
);

has permission => (
    is => 'rw',
    isa => 'Str',
    default => '755',
);

has provide => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

has remove => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    
    foreach my $key (qw(create remove)) {
        next if !exists $args{$key};
        $args{$key} = _normalize_paths($args{$key});
    }
    
    return $class->orig(\%args);
};

sub _normalize_paths {
    my @paths;
    foreach my $path (ref $_[0] eq 'HASH' ? @{$_[0]} : $_[0]) {
        if (ref $path eq 'HASH') {
            push @paths, $path;
        } else {
            my ($path, $perm) = split(':', $path);
            push @paths, { 
                path => $path, 
                ($perm ? (permission => $perm) : ()),
            };
        }
    }
    
    return \@paths;
}

sub is_present {
    my $self = shift;
    
    return if grep { -d $_->{path} } @{$self->remove};
    return if grep { !$_->_path_is_ok($_) } @{$self->create};
    
    return 1;
}

sub _path_is_ok {
    my ($self, $path) = @_;
    
    return if !-d $path->{path};
    return if !$self->_path_has_requested_permission($path->{path});
    return if !$self->_path_has_requested_owner($path->{path});
    
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
