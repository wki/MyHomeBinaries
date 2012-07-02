use Test::More;
use Test::Exception;

use ok 'Provision::DSL';

can_ok 'main', qw(OS Os os Done done);

foreach my $os (qw(OSX Ubuntu)) {
    # simulate $os
    no strict 'refs';
    local *{'Provision::DSL::os'} = sub { $os };

    is os(), $os, "os is $os";
    is Os(), $os, "Os is $os";
    is OS(), $os, "OS is $os";

    my $app = Provision::DSL::_instantiate_app_class();
    isa_ok $app, "Provision::DSL::App::$os";
    isa_ok $app, "Provision::DSL::App";

    is_deeply $app->_entity_class_for, {}, 'no entity classes defined';

    lives_ok { Provision::DSL::_create_and_export_entity_keywords('main', $app) }
             'create_and_export_entity_keywords lives';
    
    ok scalar keys %{$app->_entity_class_for} > 5,
       'more than 5 entity classes found';

    while (my ($entity_name, $entity_class) = each %{$app->_entity_class_for}) {
        like $entity_name, qr{\A [A-Z][A-Za-z0-9_]+ \z}xms, 
             "Entity '$entity_name' has a valid name";
        like $entity_class, qr{\A Provision::DSL::Entity:: (?: _ $os ::)? [A-Z][A-Za-z0-9_:]+ \z}xms, 
             "Class '$entity_class' has valid namespace";
        
        can_ok 'main', $entity_name;
    }
}

lives_ok { Provision::DSL::_create_and_export_source_keywords('main', $app) }
         'create_and_export_source_keywords lives';

foreach my $source (qw(resource url)) {
    can_ok 'main', $source, lcfirst $source;
}

done_testing;
