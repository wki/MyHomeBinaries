package Provision::Entity::Service::OSX;
use Moose;
use Provision::Types;
use Path::Class;
use namespace::autoclean;

extends 'Provision::Entity::Service';

has plist => (
    is => 'ro',
    isa => 'File',
    required => 1,
    lazy_build => 1,
    coerce => 1,
);

sub _build_plist {
    my $self = shift;
    
    ### FIXME: find plist file by label (=name)
    foreach my $dir (map { dir($_) } $self->_plist_search_paths) {
        my ($list_file, $more_things_found) =
            grep { m{\b \Q${\$self->name}\E \b}xms }
            $dir->children
        or next;

        die "plist '${\$self->name}' is not unique, service not identifyable"
            if $more_things_found;

        return $list_file;
    }
    
    ### FIXME: if plist is not found, scan for a 'copy' file
    ###        and extract its label which becomes the file name
    die 'could not find requested plist';
}

sub _plist_search_paths {
    ### FIXME: if user is given: ~user/Library/LaunchAgents ?
    return qw(
        /Library/LaunchAgents
        /Library/LaunchDaemons
    );
}

sub is_present {
    # check running === is_running
}

sub is_current {
    # check copy against plist if copy present
}

sub create {
    # running ? stop : start
}

sub _is_running {
    my $self = shift;
    
    # launchctl list | grep $self->name
}

sub _do_reload {
    my $self = shift;
}

__PACKAGE__->meta->make_immutable;
1;
