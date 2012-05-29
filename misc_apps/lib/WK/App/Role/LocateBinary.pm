package WK::App::Role::LocateBinary;
use Moose::Role;

sub locate_binary {
    my $self = shift;
    my $binary_name = shift;
    
    foreach my $path (split ':', $ENV{PATH}) {
        my $bin = "$path/$binary_name"; 
        
        return $bin if -x $bin;
    }
    
    die "could not find '$binary_name'.";
}

no Moose::Role;

1;
