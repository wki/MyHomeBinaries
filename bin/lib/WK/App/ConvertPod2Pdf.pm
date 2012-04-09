package WK::App::ConvertPod2Pdf;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class 'Dir';
use Path::Class;
use Pod::Simple;
use App::pod2pdf;
use YAML;
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt';

has filter_packages => (
    traits => ['Getopt', 'Array'],
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    handles => {
        all_filter_packages => 'elements',
        no_package_filter   => 'is_empty',
    },
    cmd_flag => 'package',
    cmd_aliases => 'p',
    documentation => 'List of wanted Package namespaces (including all children)',
);

has directory => (
    traits => ['Getopt'],
    is => 'rw',
    isa => Dir,
    coerce => 1,
    trigger => \&_check_dir_existence,
    predicate => 'has_directory',
    cmd_aliases => 'd',
    documentation => 'A Directory to use instead of @INC',
);

has module_structure => (
    traits => ['NoGetopt'],
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

has parser => (
    traits => ['NoGetopt'],
    is => 'ro',
    isa => 'App::pod2pdf',
    lazy => 1,
    default => sub { App::pod2pdf->new },
);

has pdf => (
    traits => ['NoGetopt'],
    is => 'ro',
    isa => 'PDF::API2',
    lazy => 1,
    default => sub { shift->parser->{pdf} },
);

sub _check_dir_existence {
    my ($self, $dir) = @_;

    die "Dir $dir does not exist"
        if !-d $dir;
}

### TODO: add    $self->usage->{leader_text} .= ' file_to_save.pdf';

sub run {
    my $self = shift;
    
    $self->collect_modules;
    $self->create_pdfs;
    $self->save_or_print_pdf;
}

sub collect_modules {
    my $self = shift;

    if ($self->has_directory) {
        $self->search_modules_in($self->directory);
    } else {
        $self->search_modules_in(dir($_)) for @INC;
    }
}

sub create_pdfs {
    my $self = shift;
    my $structure = shift // $self->module_structure;
    my $module_path = shift // [];

    foreach my $name (sort grep { !m{\A _}xms } keys %$structure) {
        my $node = $structure->{$name};
        my $current_path = [@$module_path, $name];
        $self->log('processing ' . join('::', @$current_path));

        $self->create_pdf($node->{_file}, $current_path)
            if exists($node->{_file});

        $self->create_pdfs($node, $current_path)
            if grep { !m{\A _}xms } keys %$node;
    }
}

sub save_or_print_pdf {
    my $self = shift;

    if (scalar @{$self->extra_argv}) {
        $self->pdf->saveas($self->extra_argv->[0]);
    } else {
        $self->parser->output;
    }
}

sub create_pdf {
    my $self = shift;
    my $file = shift;
    my $module_path = shift;
    
    my $nr_pages = $self->pdf->pages;

    $self->parser->parse_from_file($file->stringify);
    $self->parser->formfeed;

    my $structure = $self->module_structure;
    my $outline   = $structure->{_outline} ||= $self->pdf->outlines->outline;
    
    foreach my $part (@$module_path) {
        $structure = $structure->{$part};
        $structure->{_outline} //= $outline->outline;
        $outline = $structure->{_outline};
        $outline->title($part);
    }
    $outline->dest($self->pdf->openpage($nr_pages));
}

# $structure points to the current position inside module_structure
# $module_path holds the parts of a module, eg [qw(MooseX Getopt)]
sub search_modules_in {
    my $self        = shift;
    my $dir         = shift;
    my $structure   = shift // $self->module_structure;
    my $module_path = shift // [];
    
    $self->log_debug("searching in $dir");
    
    foreach my $child ($dir->children) {
        my $name         = $child->basename; $name =~ s{\.\w+ \z}{}xms;
        my $substructure = $structure->{$name} ||= {};
        my $current_path = [@$module_path, $name];

        ### TODO: find a way to eliminate children early !!!

        if ($child->is_dir) {
            $self->search_modules_in($child, $substructure, $current_path);
        } else {
            my $parser = Pod::Simple->new;
            $parser->parse_file($child->stringify);

            if ($parser->content_seen && $self->module_wanted($current_path)) {
                $substructure->{_file} //= $child;
            }
        }
    }
}

sub module_wanted {
    my $self = shift;
    my $module_path = shift;

    return 1 if $self->no_package_filter;

    my $module_name = join('::', @$module_path);
    return grep { index($module_name, $_) == 0 }
           $self->all_filter_packages;
}

__PACKAGE__->meta->make_immutable;
1;
