package WK::App::Easy::Command::cpanm;
use Modern::Perl;
use autodie ':all';
use Moose;
use LWP::UserAgent;
use Try::Tiny;

extends 'WK::App::Easy::Command';

use constant CPANM_URL => 'https://raw.github.com/miyagawa/cpanminus/master/cpanm';

override prepare => sub {
    my $self = shift;
    my $app = shift;
    
    $app->log_debug('check if we must download cpanm');
    my $cpanm_path;
    try {
        $cpanm_path = $app->find_executable_file_like(qr{\A cpanm \z}xms);
        $app->log_debug("  cpanm is here: $cpanm_path");
    } catch {
        $app->log_debug('  cpanm not present');
        my ($bin_dir) = $app->search_dirs;
        $cpanm_path = $bin_dir->file('cpanm');
    };
    
    if (!-x $cpanm_path || $cpanm_path->stat->mtime < time - 86400) {
        my $ua  = LWP::UserAgent->new;
        my $response = $ua->get(CPANM_URL);
        
        if (!$response->is_success) {
            $app->log_debug("  error loading cpanm, message: ${\$response->message}");
            die 'no cpanm binary present for executing'
                if !-x $cpanm_path;
        } else {
            $app->log_debug('  cpanm loaded');
            open my $f, '>', $cpanm_path;
            print $f $response->content;
            close $f;
            
            chmod 0755, $cpanm_path;
        }
    }
};

override run => sub {
    my $self = shift;
    my $app = shift;
    my @args = @_;
    
    my $cpanm_path = $app->find_executable_file_like(qr{\A cpanm \z}xms);
    $app->execute($cpanm_path, -L => $app->lib_dirname, @args);
};

override documentation => sub {
    return <<EOF;
cpanm -- download and run cpanm binary

automatically sets -L option pointing to app's lib directory.

all other options -- see perldoc cpanm

EOF
};

1;
