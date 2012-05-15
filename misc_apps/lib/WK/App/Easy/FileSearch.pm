package WK::App::Easy::FileSearch;
use Modern::Perl;
use Moose;
use MooseX::Types::Moose 'ArrayRef';
use MooseX::Types::Path::Class 'Dir';

has app => (
    is       => 'ro',
    isa      => 'WK::App::Easy',
    required => 1,
);

has search_dirs => (
    traits  => ['Array'],
    is      => 'rw',
    isa     => ArrayRef[Dir],
    default => sub { [] },
    handles => {
        add_search_dir => 'unshift'
    },
);

sub find {
    my $self = shift;
    my $wanted = shift || sub { 1 };
    
    my @found;
    
    foreach my $dir (@{$self->search_dirs}) {
        $self->app->log_debug("    Visiting dir: $dir");
        
        foreach my $entry ($dir->children) {
            next if !-f $entry;
            next if $entry->basename =~ m{\A \.}xms;
            
            local $_ = $entry;
            push @found, $_
                if $wanted->($_);
        }
    }

    return wantarray ? @found : $found[0];
}

__PACKAGE__->meta->make_immutable;

1;
