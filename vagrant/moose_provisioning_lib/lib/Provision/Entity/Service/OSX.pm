package Provision::Entity::Service::OSX;
use Moose;
use Provision::Types;
use Path::Class;
use namespace::autoclean;

extends 'Provision::Entity::Service';

sub _build_path {
    my $self = shift;
    
    # find an existing plist
    # or use label in "copy" plist file
    # or assume /Library/LaunchDaemons/<$self->name>

    ### FIXME: find plist file by label (=name)
    foreach my $dir ($self->_plist_search_dirs) {
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

sub _plist_search_dirs {
    ### FIXME: if user is given: ~user/Library/LaunchAgents ?
    return map { dir($_) } 
           ( qw(/Library/LaunchAgents /Library/LaunchDaemons) );
}

sub is_present {
    # check running === is_running
}

sub is_current {
    # check copy against plist if copy present
}

sub create {
    # !is_current? stop if_running, delete old file, copy 
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
