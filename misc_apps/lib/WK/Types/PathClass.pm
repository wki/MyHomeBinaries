package WK::Types::PathClass;
use Moose;
use MooseX::Types::Stringlike qw(Stringable);
use MooseX::Types::Path::Class;
use MooseX::Types -declare => [qw(ExistingFile ExecutableFile ExistingDir DistributionDir)];

=head1 NAME

WK::Types::PathClass - an extension to MooseX::Types::Path::Class

=head1 SYNOPSIS

    package Some::App;
    use Moose;
    use WK::Types::PathClass qw(ExistingFile ExistingDir 
                                ExecutableFile
                                DistributionDir);
    
    ...
    
    has some_attribute => (
        is => 'rw',
        isa => ExistingFile,
        ...
    );

=head1 DESCRIPTION

offers additional type constraints based on L<MooseX::Types::Path::Class>:


=head1 TYPES

=cut

=head2 ExistingFile

a file that must exist in the filesystem. Additionally, a coercion from
Stringable is added that resolves and converts the file to an absolute path.

=cut

subtype ExistingFile,
    as MooseX::Types::Path::Class::File,
    where { -f $_ },
    message { "File '$_' does not exist" };

coerce ExistingFile,
    (
        map {
            my $c = $_;
            ref $c eq "CODE"
                ? sub { $c->(@_)->resolve->absolute }
                : $c
        }
        @{ MooseX::Types::Path::Class::File->coercion->type_coercion_map }
    ),
    from Stringable, via { Path::Class::File->new("$_")->resolve->absolute };


=head2 ExecutableFile

a file that must exist in the filesystem and be executable. Additionally, a
coercion from Stringable is added that resolves and converts the file to an
absolute path.

=cut

subtype ExecutableFile,
    as ExistingFile,
    where { -x $_ },
    message { "File '$_' is not executable" };

coerce ExecutableFile,
    @{ ExistingFile->coercion->type_coercion_map };


=head2 ExistingDir

a directory that must exist in the filesystem. Additionally, a coercion from
Stringable is added that resolves and converts the directory to an absolute
path.

=cut

subtype ExistingDir,
    as MooseX::Types::Path::Class::Dir,
    where { -d $_ },
    message { "Directory '$_' does not exist" };

coerce ExistingDir,
    (
        map {
            my $c = $_;
            ref $c eq "CODE"
                ? sub { $c->(@_)->resolve->absolute }
                : $c
        }
        @{ MooseX::Types::Path::Class::Dir->coercion->type_coercion_map }
    ),
    from Stringable, via { Path::Class::Dir->new("$_")->resolve->absolute };


=head2 DistributionDir

a directory that must exist in the filesystem and have a file named
'Makefile.PL' inside. Additionally, a coercion from
Stringable is added that resolves and converts the directory to an absolute
path.

=cut

subtype DistributionDir,
    as ExistingDir,
    where { -f "$_/Makefile.PL" },
    message { "Directory $_ does not contain a distribution" };

coerce DistributionDir,
    @{ ExistingDir->coercion->type_coercion_map };

1;

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
