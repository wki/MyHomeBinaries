package Provision::DSL::Source::Resource;
use Moose;
use FindBin;
use Provision::DSL::Types;
use namespace::autoclean;

extends 'Provision::DSL::Source';

has root_dir => (
    is => 'ro',
    isa => 'ExistingDir',
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

sub _build_root_dir { "$FindBin::Bin/resources" }

has path => (
    is => 'ro',
    isa => 'PathClassEntity',
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

sub _build_path { 
    my $self = shift;
    
    my $thing = $self->root_dir->subdir($self->name)->cleanup;
    if (!-d $thing) {
        $thing = $self->root_dir->file($self->name)->cleanup;
        die "Resource-path does not exist: '${\$self->name}'"
            if !-f $thing;
    }
    
    return $thing->resolve;
}

sub _build_content {
    my $self = shift;
    
    die 'dir-resources cannot retrieve content' if -d $self->path;
    die 'file-resource does not exist' if !-f $self->path;
    
    return scalar $self->path->slurp;
}

__PACKAGE__->meta->make_immutable;
1;
