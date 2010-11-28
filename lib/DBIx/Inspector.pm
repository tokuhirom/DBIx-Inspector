package DBIx::Inspector;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/dbh catalog schema driver/);
use Carp ();
use DBIx::Inspector::Table;
use DBIx::Inspector::Iterator;
use DBIx::Inspector::ForeignKey;
use Class::Load;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    my $dbh = $args{dbh};
    Carp::croak("missing mandatory parameter: dbh") unless $dbh;
    my $driver_name = $dbh->{Driver}->{Name};
    my $driver_class = "$class\::Driver::$driver_name";
    Class::Load::load_class($driver_class);
    return $driver_class->new(%args);
}

1;
__END__

=encoding utf8

=head1 NAME

DBIx::Inspector -

=head1 SYNOPSIS

  use DBIx::Inspector;

=head1 DESCRIPTION

DBIx::Inspector is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
