package Provision::Types;
use Provision;
use Moose::Util::TypeConstraints;
use Path::Class;

class_type 'UserEntity',
    { class => 'Provision::Entity::User' };
coerce 'UserEntity',
    from 'Str',
    via { User $_ };


class_type 'GroupEntity',
    { class => 'Provision::Entity::Group' };
coerce 'GroupEntity',
    from 'Str',
    via { Group $_ };


subtype 'Permission',
    as 'Str',
    where { m{\A [0-7]{3} \z}xms },
    message { 'a permission must be a 3-digit octal number' };


class_type 'File',
    { class => 'Path::Class::File' };
coerce 'File',
    from 'Str',
    via { Path::Class::File->new($_) };


class_type 'Dir',
    { class => 'Path::Class::Dir' };
coerce 'Dir',
    from 'Str',
    via { Path::Class::Dir->new($_) };


subtype 'DirList',
    as 'ArrayRef',
    where { !grep { ref $_ ne 'HASH' || !exists $_->{path} } @$_ },
    message { 'invalid content for a dirlist' };
coerce 'DirList',
    from 'Str',
        via { [ { path => $_ } ] },
    from 'ArrayRef',
        via { [ map { ref $_ ? $_ : { path => $_ } } @$_ ] };


no Moose::Util::TypeConstraints;
1;
