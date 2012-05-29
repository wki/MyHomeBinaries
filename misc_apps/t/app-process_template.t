use Test::More;
use Test::Exception;
use FindBin;

use ok 'WK::App::ProcessTemplate';

my $app = WK::App::ProcessTemplate->new(
    config_dir => "$FindBin::Bin/config",
    template_filename => 'something.sh.tpl',
    config_suffix => 'dd',
    
    # debug => 1, # remove after success
);

is_deeply $app->config_vars,
          {
              name => 'Foo',
              description => 'a Foo thing',
              info => {
                  bah => 'A Foo Bah: a Foo thing',
                  bar => 'BAR',
              },
          },
          'config correctly merged';

is $app->process_template,
   'Something Foo - Info: BAR',
   'rendered template is OK';

done_testing;
