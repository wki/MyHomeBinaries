package WK::Types::PathClass;
use Moose;
use MooseX::Types::Stringlike qw(Stringable);
use MooseX::Types::Path::Class;
use MooseX::Types -declare => [qw(ExistingFile ExecutableFile ExistingDir DistributionDir)];


subtype ExistingFile,
    as MooseX::Types::Path::Class::File,
    where { -f $_ },
    message { "File $_ does not exist" };

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


subtype ExecutableFile,
    as ExistingFile,
    where { -x $_ },
    message { "File $_ is not executable" };

coerce ExecutableFile,
    @{ ExistingFile->coercion->type_coercion_map };


subtype ExistingDir,
    as MooseX::Types::Path::Class::Dir,
    where { -d $_ },
    message { "Directory $_ does not exist" };

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


subtype DistributionDir,
    as ExistingDir,
    where { -f "$_/Makefile.PL" },
    message { "Directory $_ does not contain a distribution" };

coerce DistributionDir,
    @{ ExistingDir->coercion->type_coercion_map };


1;
