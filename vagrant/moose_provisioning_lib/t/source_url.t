use Test::More;

use ok 'Provision::DSL::Source::Url';

my $ip = gethostbyname('www.cpan.org')
    or do {
        diag 'Not connected to the internet, skipping';
        done_testing;
        exit;
    };

my $u = Provision::DSL::Source::Url->new('http://www.cpan.org');
like $u->content, qr{<title>.*Comprehensive.*</title>}xms,
     'html content looks good';

done_testing;
