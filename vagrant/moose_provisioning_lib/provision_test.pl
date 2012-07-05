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

Kinds of entities:
 - Dir, File, Tree
    * config-file might trigger ???
 - Execution of scripts triggered by a condition
 - Installation/Setup
    * Users, Groups
    * Packages
    * Download, compile things from source (*brew, cpan, C, ...)
 - Services
    * System Daemons
    * User created daemons

# changed Syntax examples
# -----------------------

# resources/templates
  Resource('path/to/file')
  Resource('path/to/dir')
  Template('path/to/file', { vars => {...}, ... })


# create/remove -- ???
  create => <any>               # type depends on entity
  remove => <any>
  
  Single Entities: internal state: *=end-state
    - missing, out-of-date, current*, removed*

  Compound Entities: internal state:
    - list of missing things   --> present after create
    - list of present things   --> evtl to-change, to-remove
    - list of to-change things --> present after change
    - list of to-remove thing  --> removed after change
    - list og removed things
  
# generic callback attributes -- TODO
  before_create => sub {}
  before_remove => sub {}
  before_change => sub {}
  after_create => sub {}
  after_remove => sub {}
  after_change => sub {}


# creating a user:

User 'sites';                   # uid read or guessed, group 'sites' [123]
User sites => ( uid => 123 );   # group read or 'sites' [123]
User sites => ( uid => 123, group => 'xxx' );
User sites => ( uid => 123, group => Group('xxx') );
User sites => ( uid => 123, group => Group('xxx', gid => 111) );
### TODO: add "groups => [ ... ]"


# service nginx, implicitly requires package nginx
Nginx {
    runlevel => [1..5],         # default: 2-3 ???

    # sites
    create => {
        site_name => resource('site/site_name.conf'),
    },
    remove => [
        'other_site_name',
    ]
};

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
    create     => 1,    # is default, 0 removes
    content    => resource('path/to/website'),
);

File '/path/to/mysite_js' => (
    user       => 'sites',
    group      => 'sites',
    permission => 0644,
    content    => 'asdfsdf', # or resource('js/site.js'),
    create     => 1, # is default, 0 removes
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
    after_change => Nginx->reload,
    after_change => [
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
    create  => 1,  # default: 1, 0 removes
    copy    => resource('/plist/pdf.plist'), # or a linux shell script
);

Exec 'deploy mysite' => (
    path    => '/path/to/executable',
    args    => { '--foo' => 'bar' },
    env     => { PERL5LIB => '/path/to/lib' },
    only_if => sub {},
);

done;
