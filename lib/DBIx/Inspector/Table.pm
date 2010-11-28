package DBIx::Inspector::Table;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/inspector/);
use DBIx::Inspector::Column;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless {%args}, $class;
}

sub columns {
    my ($self, $column) = @_;
    $column = '%' if not defined $column;

    my $sth = $self->inspector->dbh->column_info( $self->inspector->catalog, $self->inspector->schema, $self->name, $column );
    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { DBIx::Inspector::Column->new(table => $self, %{$_[0]}) },
        sth =>$sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub primary_key {
    my $self = shift;
    my $sth = $self->inspector->dbh->primary_key_info( $self->inspector->catalog, $self->inspector->schema, $self->name );
    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { DBIx::Inspector::Column->new(table => $self, %{$_[0]}) },
        sth =>$sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub name    { $_[0]->{TABLE_NAME} }
sub catalog { $_[0]->{TABLE_CAT} }
sub schema  { $_[0]->{TABLE_SCHEM} }
sub type    { $_[0]->{TABLE_TYPE} }

1;

