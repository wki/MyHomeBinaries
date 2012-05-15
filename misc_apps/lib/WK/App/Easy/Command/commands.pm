package WK::App::Easy::Command::commands;
use Modern::Perl;
use Moose;
use List::MoreUtils 'uniq';

extends 'WK::App::Easy::Command';

override run => sub {
    my $self = shift;
    my $app  = shift;

    my @commands =
        sort
        uniq
        map { s{\A .* ::}{}xms; $_ }
        $app->get_command_classes;
    
    my %binary_for;
    foreach my $file ($app->file_search->find) {
        next if !-f $file;
        next if !-x $file;
        
        my $filename = $file->basename;
        my $command = $filename;
        $command =~ s{\A \L${\$app->app_name}\E _}{}xms;
        $command =~ s{\.[a-zA-Z]+ \z}{}xms;
        
        my $path = "$file";
        $path =~ s{${\$app->app_directory}}{...};
        $binary_for{$command} //= $path;
    }
    
    delete $binary_for{$_} for @commands;
    
    my @binaries =
        map { sprintf '%-20s   %s', $_,  $binary_for{$_} }
        sort
        keys %binary_for;
    
    say 'Commands available:';
    say "    $_" for @commands;
    say '';
    say 'Binaries available:';
    say "    $_" for @binaries;
};

1;
