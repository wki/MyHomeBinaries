package WK::App::ConvertPod2Pdf;
use Modern::Perl;
use Moose;
use MooseX::Types::Path::Class qw(File Dir);
use Path::Class;
use Pod::Simple;
use Config;
use App::pod2pdf;
use YAML;
use namespace::autoclean;

extends 'WK::App';
with 'MooseX::Getopt';

has filter_packages => (
    traits => ['Getopt', 'Array'],
    is => 'rw',
    isa => 'ArrayRef[Str]',
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
    trigger => sub { -d $_[1] or die "directory $_[1] does not exist " },
    predicate => 'has_directory',
    cmd_aliases => 'd',
    documentation => 'A Directory to use instead of @INC',
);

has toc_file => (
    traits => ['Getopt'],
    is => 'rw',
    isa => File,
    coerce => 1,
    trigger => sub { -f $_[1] or die "toc file $_[1] does not exist " },
    predicate => 'has_toc_file',
    cmd_aliases => 't',
    documentation => 'an optional file containing a Table of contents',
);

has target_file => (
    traits => ['Getopt'],
    is => 'rw',
    isa => File,
    coerce => 1,
    predicate => 'has_target_file',
    cmd_flag => 'save_to',
    cmd_aliases => 'f',
    documentation => 'A File to save to instead of STDOUT',
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

sub run {
    my $self = shift;

    $self->collect_modules;
    $self->create_pdf;
    $self->save_or_print_pdf;
}

sub collect_modules {
    my $self = shift;

    $self->log('Collecting Modules...');

    if ($self->has_directory) {
        $self->search_modules_in($self->directory);
    } else {
        $self->search_modules_in(dir($_)) for @INC;
    }
}

sub create_pdf {
    my $self = shift;

    $self->log('creating PDF...');
    $self->create_toc;
    $self->process_structure($self->module_structure, []);
}

sub create_toc {
    my $self = shift;
    
    return if !$self->has_toc_file;
    
    $self->add_file_to_pdf($self->toc_file, ['Table Of Contents']);
}

sub process_structure {
    my $self = shift;
    my $structure = shift;
    my $module_path = shift;

    foreach my $name (sort grep { !m{\A _}xms } keys %$structure) {
        my $node = $structure->{$name};
        my $current_path = [@$module_path, $name];
        $self->log_debug('processing ' . join('::', @$current_path));

        $self->add_file_to_pdf($node->{_file}, $current_path)
            if exists($node->{_file});

        $self->process_structure($node, $current_path)
            if grep { !m{\A _}xms } keys %$node;
    }
}

sub save_or_print_pdf {
    my $self = shift;

    $self->log('Saving...');
    if ($self->has_target_file) {
        $self->pdf->saveas($self->target_file->stringify);
    } else {
        $self->parser->output;
    }
}

sub add_file_to_pdf {
    my $self = shift;
    my $file = shift;
    my $module_path = shift;

    my $nr_pages = $self->pdf->pages;

    $self->parser->parse_from_filehandle($file->open('<:utf8'));
    $self->parser->formfeed;

    my $structure = $self->module_structure;
    my $outline = $self->pdf->outlines;

    foreach my $part (@$module_path) {
        $structure = $structure->{$part};
        $outline = $structure->{_outline} //= $outline->outline;
        $outline->title($part);
    }
    $outline->dest($self->pdf->openpage($nr_pages));
}

# $structure points to the current position inside module_structure
# $module_path holds the parts of a module, eg [qw(MooseX Getopt)]
sub search_modules_in {
    my ($self, $dir) = @_;
    
    $self->_search_modules_in($dir);
    
    my $arch_subdir = $dir->subdir($Config{archname});
    $self->_search_modules_in($arch_subdir) if -d $arch_subdir;
}

sub _search_modules_in {
    my $self        = shift;
    my $dir         = shift;
    my $structure   = shift // $self->module_structure;
    my $module_path = shift // [];

    $self->log_debug("searching in $dir");

    foreach my $child ($dir->children) {
        my $name         = $child->basename; $name =~ s{\.\w+ \z}{}xms;
        next if $name =~ m{\A \.}xms;
        
        my $substructure = $structure->{$name} ||= {};
        my $current_path = [@$module_path, $name];

        if ($child->is_dir) {
            if ($self->dir_wanted($current_path)) {
                $self->_search_modules_in($child, $substructure, $current_path);
            } else {
                $self->log_debug("bailing out at $child");
            }
        } else {
            my $parser = Pod::Simple->new;
            $parser->parse_file($child->stringify);

            if ($parser->content_seen && $self->module_wanted($current_path)) {
                $substructure->{_file} //= $child;
            }
        }
    }
}

sub dir_wanted {
    my $self = shift;
    my $module_path = shift;

    return 1 if $self->no_package_filter;

    my $module_name = join('::', @$module_path);
    return grep { index($_, $module_name) == 0 || index($module_name, $_) == 0 }
           $self->all_filter_packages;
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
