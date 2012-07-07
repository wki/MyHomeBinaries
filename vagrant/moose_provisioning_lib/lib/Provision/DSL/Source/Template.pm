package Provision::DSL::Source::Template;
use Moose;
use Template;
use namespace::autoclean;

extends 'Provision::DSL::Source::Resource';

has vars => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

sub _build_content {
    my $self = shift;
    
    die 'a directory cannot act as a template' if -d $self->path;
    die 'template file does not exist' if !-f $self->path;
    
    my $output = '';
    my $renderer = Template->new(
        INCLUDE_PATH => $self->path->dir,
        INTERPOLATE  => 0,
        POST_CHOMP   => 0,
        EVAL_PERL    => 1,
    );
    
    $renderer->process($self->path->basename, $self->vars, \$output)
        or die "Error: ${\$renderer->error}";

    return $output;
}

__PACKAGE__->meta->make_immutable;
1;
