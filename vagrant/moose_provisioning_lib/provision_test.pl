#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/lib";
use Provision;

my $DOMAIN   = "www.mysite.de";
my $SITE_DIR = "/web/data/$DOMAIN";

User 'sites', (
    uid => 513,
    gid => 513,
    # on_create => sub { },
    # on_change => sub { },
);

User 'wolfgang';

Package 'automake';
Package 'wget';

Perlbrew sites => (
    # user_name      => 'sites', # guessed from name
    install_cpanm  => 1,
    install_perl   => '5.14.2', # or an array
    switch_to_perl => '5.14.2',
);

done;

__END__

Nginx nginx => (
    service => 'running',
    runlevel => [1..5],
    # site => (name => ..., ... ),
);

Nginx_Site 'www.mysite.de' => (
    listen => 80,
    root => "$SITE_DIR/htdocs",
    on_change => Nginx('nginx')->reload, # or ->service->reload
);

### alternativ:

Nginx('nginx',
    service => 'running',
    runlevel => [1..5],
)->Site('www.mysite.de',
    listen => 80,
    root => "$SITE_DIR/htdocs",
);

Perlbrew sites => (
    user           => 'sites', # guessed from name
    install_cpanm  => 1,
    install_perl   => '5.14.2', # or an array
    switch_to_perl => '5.14.2',
);

Files 'www.mysite.de',
    user => 'sites',
    group => 'sites',
    permission => 0755,
    directory => "$SITE_DIR:755",
    directories => [
        "$SITE_DIR/bla:755",
        "$SITE_DIR/foo:777",
        { path => '/foo/bar', permission => 0755 },
    ],
    file => 'asdf',
    files => [ 
        'xxx:644',
        { path => 'baz', ... }
    ];

Catalyst 'www.mysite.de',
    directory => "$SITE_DIR/MySite",
    copy_from => Resource('/tmp/xxx'),
    user => 'sites',
    perl => Perlbrew('sites')->perl;

Exec 'deploy www.mysite.de',
    path => '/path/to/executable',
    args => { '--foo' => 'bar' },
    env  => { PERL5LIB => '/path/to/lib' };

done;
