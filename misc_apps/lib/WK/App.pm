package WK::App;
use Modern::Perl;
use Moose;
with 'MooseX::Getopt';

=head1 NAME

WK::App - Base class for applications

=head1 SYNOPSIS

    package WK::App::Foo;
    use Moose;
    extends 'WK::App';

    sub whatever {
        my $self = shift;

        $self->log('some message printed if verbose');

        $self->log_debug('seen in debug mode');

        $self->log_dryrun('would delete files') and return;
        
        # do something dangerous, eg:
        $files->delete;
    }

=head1 DESCRIPTION

handles the common part of all applications.

=head1 ATTRIBUTES

=cut

=head2 verbose

a boolean that decides if verbosity is on or off

=cut

has verbose => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    cmd_aliases   => 'v',
    documentation => 'print what the script is about to do',
);

=head2 debug

a boolean that decides if debug mode is on or off

=cut

has debug => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    documentation => 'print (many) debug messages',
);

=head2 dryrun

a boolean that decides if dryrun mode is on or off

=cut

has dryrun => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    cmd_aliases   => 'n',
    documentation => 'simulate a run',
);

=head1 METHODS

=cut

=head2 log ( @messages )

if verbose mode is on, @message is printed to STDERR

returns true if verbose mode is on

=cut

sub log {
    my $self = shift;
    $self->_log_if($self->verbose || $self->debug, @_);
}

=head2 log_debug ( @messages )

if debug mode is on, @message is printed to STDERR

returns true if debug mode is on

=cut

sub log_debug {
    my $self = shift;
    $self->_log_if($self->debug, 'DEBUG:', @_);
}

=head2 log_dryrun ( @messages )

if dryrun mode is on, @message is printed to STDERR

returns true if dryrun mode is on

=cut

sub log_dryrun {
    my $self = shift;
    $self->_log_if($self->dryrun, @_);
}

sub _log_if {
    my $self = shift;
    my $condition = shift;

    say STDERR join(' ', @_) if $condition;

    return $condition;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
