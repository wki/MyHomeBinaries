package Provision::DSL::CheckIf::FileExists;
use Moose;
use Provision::DSL::Types;
use namespace::autoclean;

extends 'Provision::DSL::CheckIf';

has path => (
    is => 'ro',
    isa => 'PathClassFile',
    coerce => 1,
    required => 1,
    lazy_build => 1,
);

sub _build_path { $_[0]->entity->name }

around BUILDARGS => sub {
    my ($orig, $class) = @_;
    
    if (@_ == 1) {
        return $class->$orig(path => $_[0]);
    } else {
        return $class->$orig(@_);
    }
};

sub is_ok { -f $_[0]->path }

__PACKAGE__->meta->make_immutable;
1;
