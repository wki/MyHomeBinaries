package Provision::DSL::Types;
use Moose::Util::TypeConstraints;
use Path::Class;


# class_type 'UserEntity',
#     { class => 'Provision::Entity::User' };
# coerce 'UserEntity',
#     from 'Str',
#     via { User $_ };
# 
# 
# class_type 'GroupEntity',
#     { class => 'Provision::Entity::Group' };
# coerce 'GroupEntity',
#     from 'Str',
#     via { Group $_ };


subtype 'Permission',
    as 'Str',
    where { m{\A [0-7]{3} \z}xms },
    message { 'a permission must be a 3-digit octal number' };


class_type 'PathClassEntity',
    { class => 'Path::Class::Entity' };
coerce 'PathClass',
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


class_type 'Entity',
    { class => 'Provision::DSL::Entity' };

class_type 'User',
    { class => 'Provision::DSL::Entity::User' };
coerce 'User',
    from 'Str',
    via { Provision::DSL::Entity::User->new({name => $_}) }; ### FIXME: OS!


class_type 'Group',
    { class => 'Provision::DSL::Entity::Group' };
coerce 'Group',
    from 'Str',
    via { Provision::DSL::Entity::Group->new({name => $_}) }; ### FIXME: OS!


class_type 'Source',
    { class => 'Provision::DSL::Source' };


subtype 'SourceContent',
    as 'Str';
coerce 'SourceContent',
    from 'Source',
        via { $_->content };


no Moose::Util::TypeConstraints;
1;
