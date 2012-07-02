package Provision::DSL::Source::Url;
use Moose;
use LWP::Simple;
use namespace::autoclean;

extends 'Provision::DSL::Source';

has url => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

sub _build_url { $_[0]->name }

sub _build_content { get($_[0]->url) }

__PACKAGE__->meta->make_immutable;
1;
