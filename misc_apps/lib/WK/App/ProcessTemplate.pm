package WK::App::ProcessTemplate;
use Modern::Perl;
use autodie ':all';
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use Config::Any;
use Template;
use YAML;
use Data::Dumper;

extends 'WK::App';

has template_filename => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    required => 1,
    cmd_aliases => 't',
    documentation => 'Template file inside config_dir to process',
);

has config_dir => (
    traits => ['Getopt'],
    is => 'ro',
    isa => Dir,
    coerce => 1,
    required => 1,
    cmd_aliases => 'c',
    documentation => 'Directory containing config files',
);

has config_suffix => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    predicate => 'has_config_suffix',
    cmd_aliases => 's',
    documentation => 'Suffix of an optional additional config file',
);

sub run {
    my $self = shift;

    $self->log_debug(template => $self->template_filename);

    my $output = '';
    my $renderer = Template->new(
        INCLUDE_PATH => $self->config_dir,
        INTERPOLATE  => 0,
        POST_CHOMP   => 0,
        EVAL_PERL    => 1,
    );

    $renderer->process($self->template_filename, $self->config_vars, \$output)
        or die 'Error: ' . $renderer->error;

    say $output;
}

sub config_vars {
    my $self = shift;

    my $config = Config::Any->load_stems(
        {
            stems => [
                $self->config_dir->file($self->config_dir->basename),
                ($self->has_config_suffix
                    ? $self->config_dir->file($self->config_dir->basename . '_' . $self->config_suffix)
                    : ()),
            ],
            use_ext => 1,
        }
    );
    $self->log_debug('RAW CONFIG:', Dumper $config);

    my %merged_config =
        map { %$_ }
        grep { ref }
        map { %$_ }
        @$config;

    $self->interpolate(\%merged_config);
    $self->log_debug('INTERPOLATED CONFIG:', Dumper \%merged_config);

    return \%merged_config;
}

sub interpolate {
    my $self = shift;
    my $hash = shift;
    my $variables = shift // $hash;
    
    foreach my $value (values %$hash) {
        if (ref $value eq 'HASH') {
            $self->interpolate($value, $variables);
        } else {
            $value =~ s{\$(\w+)}{$variables->{$1}}xmsg
                while $value =~ m{\$}xms;
        }
    }
}


__PACKAGE__->meta->make_immutable;

1;
