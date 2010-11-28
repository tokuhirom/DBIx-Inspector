package DBIx::Inspector;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/dbh catalog schema/);
use Carp ();
use DBIx::Inspector::Table;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    my $dbh = $args{dbh};
    Carp::croak("missing mandatory parameter: dbh") unless $dbh;
    my $driver = $dbh->{Driver}->{Name};

    # default schema name for Pg is 'public'
    if (not exists $args{schema}) {
        if ($driver eq 'Pg') {
            $args{schema} = 'public';
        }
    }
    return bless {catalog => undef, %args}, $class;
}

sub tables {
    my $self = shift;

    my $sth = $self->{dbh}->table_info( $self->catalog, $self->schema, my $table=undef, my $type='TABLE' );
    return
      map { DBIx::Inspector::Table->new( inspector => $self, %{$_} ) }
      @{ $sth->fetchall_arrayref( {} ) };
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
