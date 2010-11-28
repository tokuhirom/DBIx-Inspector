package DBIx::Inspector::Column;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/table/);

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless {%args}, $class;
}

sub name { $_[0]->{COLUMN_NAME} }

1;
