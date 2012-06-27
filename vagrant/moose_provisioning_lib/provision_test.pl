#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/lib";
use Provision;

my $DOMAIN   = "www.mysite.de";
my $SITE_DIR = "/web/data/$DOMAIN";
my $SITE_APP = "$SITE_DIR/MySite",

User sites => (
    uid => 513,
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

# changed Syntax examples
# -----------------------

# generic attributes:
  on_create => sub {}
  on_change => sub {}


# creating a user:

User 'sites';                   # uid read or guessed, group 'sites' [123]
User sites => ( uid => 123 );   # group read or 'sites' [123]
User sites => ( uid => 123, group => 'xxx' );
User sites => ( uid => 123, group => Group('xxx') );
User sites => ( uid => 123, group => Group('xxx', gid => 111) );
### TODO: add "groups => [ ... ]"


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

Tree $SITE_DIR => (
    user       => 'sites',
    group      => 'sites',
    permission => 0755,
    remove     => [],  # remove => '.' to remove dir
    create     => [
        'logs',
        'htdocs:750',
        {
            path => 'subdir/Mysite',
            permission => 0750,
            user => '...',
            group => '...',
        },
    ],
);

Dir '/path/to/directory' => (
    user       => 'sites',
    group      => 'sites',
    permission => 0644,
    create     => 1,    # is default
  # remove     => 1,    # to remove
);

File '/path/to/mysite_js' => (
    user       => 'sites',
    group      => 'sites',
    permission => 0644,
    content    => 'asdfsdf', # or resource('js/site.js'),
  # remove     => 1,    # to remove
);

# or a more generic name "WebApp" ???
Catalyst $SITE_APP => (
    user      => 'sites',
    group     => 'sites', # default: user's default group
    # alternate directory specifications (default: path taken from name)
    # directory will be created if not exists and chowned to user/group
    path      => "$SITE_DIR/MySite",
    path      => Tree($DOMAIN)->dir('MySite');
    copy      => resource('/tmp/xxx'),
    perl      => Perlbrew('sites')->perl,

    # alternative actions after install/update:
    on_change => Nginx->reload,
    on_change => [
        Service($SITE)->reload,
        Service('nginx')->reload,
    ],
);

# label is the identification
Service 'org.macports.postgresql91-server';

Service 'mysite_pdf_generator' => (
    # user/group are optional
    user    => 'sites',
    group   => 'sites',
    # more things needed
    running => 1,  # default: 1
    copy    => resource('/plist/pdf.plist'),
);

Exec 'deploy mysite' => (
    path => '/path/to/executable',
    args => { '--foo' => 'bar' },
    env  => { PERL5LIB => '/path/to/lib' },
    only_if => 'whatever',
);

done;
