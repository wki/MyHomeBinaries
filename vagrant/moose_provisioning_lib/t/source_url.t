use Test::More;

use ok 'Provision::DSL::Source::Url';

my $u = Provision::DSL::Source::Url->new('http://www.cpan.org');
like $u->content, qr{<title>.*Comprehensive.*</title>}xms,
     'html content looks good';

done_testing;
