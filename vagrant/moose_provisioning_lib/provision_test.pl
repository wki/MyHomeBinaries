#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/lib";
use Provision;

my $DOMAIN   = "www.mysite.de";
my $SITE_DIR = "/web/data/$DOMAIN";

User sites => (
    uid => 513,
    gid => 513,
    # on_create => sub { },
    # on_change => sub { },
);

User 'wolfgang';

Package 'automake';
Package 'wget';

Perlbrew sites => (
    # user => User('sites'),
    install_cpanm  => 1,
    install_perl   => '5.14.2', # or an array
    switch_to_perl => '5.14.2',
);

done;

__END__

Nginx {
    service => 'running',
    runlevel => [1..5],
    # site => (name => ..., ... ),
};

Nginx_Site 'www.mysite.de' => {
    listen => 80,
    root => "$SITE_DIR/htdocs",
    on_change => Nginx('nginx')->reload, # or ->service->reload
};

### alternativ:

Nginx('nginx',
    service => 'running',
    runlevel => [1..5],
)->Site('www.mysite.de',
    listen => 80,
    root => "$SITE_DIR/htdocs",
);

Nginx->Site('www.xxx', ...);

Perlbrew sites => (
    user           => 'sites', # guessed from name
    install_cpanm  => 1,
    install_perl   => '5.14.2', # or an array
    switch_to_perl => '5.14.2',
);

Tree 'www.mysite.de' => (
    user => 'sites',        # or 'sites:sites'
    group => 'sites',
    permission => 0755,
    base_path => '/web/data/www.mysite.de',
    create => [
        'logs',
        'htdocs:750',
        { path => 'Mysite', permission => 0750, user => '...', group => ... },
    ],
    remove => [
    ],
);

File 'mysite_js' => (
    user => 'sites',        # or 'sites:sites',
    group => 'sites',
    permission => 0644,
    # alternative path definitions
    path => '/web/data/www.mysite.de/Mysite/root/static/_js/site.js',
    path => Tree('www.mysite.de')->base_path->file('Mysite/root/static/_js/site.js'),
    # filling the file
    content => 'asdfsdf',
    content => resource('js/site.js'),
);

Catalyst 'www.mysite.de' => (
    directory => "$SITE_DIR/MySite",
    copy_from => resource('/tmp/xxx'),
    user => 'sites',
    perl => Perlbrew('sites')->perl,
);

Exec 'deploy www.mysite.de' => (
    path => '/path/to/executable',
    args => { '--foo' => 'bar' },
    env  => { PERL5LIB => '/path/to/lib' },
);

done;
