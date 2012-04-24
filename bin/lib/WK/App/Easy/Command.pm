package WK::App::Easy::Command;
use Modern::Perl;
use Moose;

sub run {
    my $self = shift;
    
    die "method 'run' must be overloaded in class ${\ref $self}";
}

sub prepare {
    my $self = shift;
    
    # overload this method and do something if needed
}

sub documentation {
    my $self = shift;
    
    # overload and return additional help ment for help <command>
    return;
}

1;
