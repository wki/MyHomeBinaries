use Test::More;
use Test::Exception;
use FindBin;

use ok 'WK::App::ProcessTemplate';

# single config file
{
    my $app = WK::App::ProcessTemplate->new(
        config_dir        => "$FindBin::Bin/config",
        template_filename => 'something.sh.tpl',
    );
    
    is_deeply $app->config_vars,
              {
                  name => 'Foo',
                  description => 'a Foo thing',
                  info => {
                      bah => 'A Foo Bah: a Foo thing',
                  },
              },
              'config correctly merged';
    
    is $app->process_template,
       'Something Foo - Info: ',
       'rendered template is OK';
}

# with suffix file
{
    my $app = WK::App::ProcessTemplate->new(
        config_dir        => "$FindBin::Bin/config",
        template_filename => 'something.sh.tpl',
        config_suffix     => 'dd',
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
}

done_testing;
