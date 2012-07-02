package Provision::DSL::Types;
use Moose::Util::TypeConstraints;
use Path::Class;


subtype 'Permission',
    as 'Str',
    where { m{\A [0-7]{3} \z}xms },
    message { 'a permission must be a 3-digit octal number' };


class_type 'PathClassEntity',
    { class => 'Path::Class::Entity' };
coerce 'PathClassEntity',
    from 'Str',
    via { -d $_ ? Path::Class::Dir->new($_) : Path::Class::File->new($_) };


class_type 'PathClassFile',
    { class => 'Path::Class::File' };
coerce 'PathClassFile',
    from 'Str',
    via { Path::Class::File->new($_) };


class_type 'PathClassDir',
    { class => 'Path::Class::Dir' };
coerce 'PathClassDir',
    from 'Str',
    via { Path::Class::Dir->new($_) };


subtype 'ExistingDir',
    as 'PathClassDir',
    where { -d $_ },
    message { "Directory $_ does not exist" };
coerce 'ExistingDir',
    from 'Str',
    via { Path::Class::Dir->new($_)->resolve->absolute };


subtype 'DirList',
    as 'ArrayRef',
    where { !grep { ref $_ ne 'HASH' || !exists $_->{path} } @$_ },
    message { 'invalid content for a dirlist' };
coerce 'DirList',
    from 'Str',
        via { [ { path => $_ } ] },
    from 'ArrayRef',
        via { [ map { ref $_ ? $_ : { path => $_ } } @$_ ] };


class_type 'Entity',
    { class => 'Provision::DSL::Entity' };


class_type 'Source',
    { class => 'Provision::DSL::Source' };


subtype 'SourceContent',
    as 'Str';
coerce 'SourceContent',
    from 'Source',
        via { $_->content };


no Moose::Util::TypeConstraints;
1;
