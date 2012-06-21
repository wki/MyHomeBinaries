package Provision::App;
use Moose;
use namespace::autoclean;
with 'MooseX::Getopt::Strict';

has verbose => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
    cmd_aliases => 'v',
);

has debug => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has dryrun => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Bool',
    default => 0,
    cmd_aliases => 'n',
);

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

# has info_for_package => (
#     is => 'rw',
#     isa => 'HashRef',
# );
# 
# sub get_info_for_package {
#     my ($self, $package) = @_;
#     
#     return $self->info_for_package->{$package}
#            //= $self->_get_info_for_package($package);
# }
# 
# sub _get_info_for_package { die '_get_info_for_package unimplemented' }

__PACKAGE__->meta->make_immutable;
1;
