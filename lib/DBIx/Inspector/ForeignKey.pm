package DBIx::Inspector::ForeignKey;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/inspector/);

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless {%args}, $class;
}

{
    no strict 'refs';
    for my $k (
        qw/PKTABLE_NAME FKTABLE_NAME FKCOLUMN_NAME PK_NAME DEFERABILITY FKTABLE_CAT PKTABLE_SCHEM KEY_SEQ PKTABLE_CAT UNIQUE_OR_PRIMARY FKTABLE_SCHEM PKCOLUMN_NAME DELETE_RULE FK_NAME/
      )
    {
        *{ __PACKAGE__ . "::" . lc($k) } = sub { $_[0]->{$k} };
    }
}

1;

