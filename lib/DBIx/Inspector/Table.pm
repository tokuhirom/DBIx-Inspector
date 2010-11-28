package DBIx::Inspector::Table;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/inspector/);
use DBIx::Inspector::Column;
use DBIx::Inspector::ForeignKey::Pg;
use DBIx::Inspector::Iterator::Null;

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

sub column {
    my ($self, $column) = @_;
    return $self->columns($column)->next;
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

sub pk_foreign_keys {
    my ($self, $opt) = @_;

    my $sth = $self->inspector->dbh->foreign_key_info(
        $self->inspector->catalog,
        $self->inspector->schema,
        $self->name,
        $opt->{fk_catalog} || $self->inspector->catalog,
        $opt->{fk_schema}  || $self->inspector->schema,
        $opt->{fk_table},
    );
    if (!$sth) {
        if ($self->inspector->driver eq 'Pg') {
            # DBD::Pg returns undef when not matched
            return DBIx::Inspector::Iterator::Null->new();
        } else {
            Carp::croak($self->inspector->dbh->errstr);
        }
    }
    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { $self->inspector->create_foreign_key( $_[0] ) },
        sth      => $sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub fk_foreign_keys {
    my ($self, $opt) = @_;

    my $sth = $self->inspector->dbh->foreign_key_info(
        $opt->{pk_catalog} || $self->inspector->catalog,
        $opt->{pk_schema}  || $self->inspector->schema,
        $opt->{pk_table},
        $self->inspector->catalog,
        $self->inspector->schema,
        $self->name
    );
    if (!$sth) {
        if ($self->inspector->driver eq 'Pg') {
            # DBD::Pg returns undef when not matched
            return DBIx::Inspector::Iterator::Null->new();
        } else {
            Carp::croak($self->inspector->dbh->errstr);
        }
    }
    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { $self->inspector->create_foreign_key($_[0]) },
        skip_cb  => sub { $_[0]->{FK_NAME} eq 'PRIMARY' }, # XXX DBD::mysql has a bug
        sth =>$sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub name    { $_[0]->{TABLE_NAME} }
sub catalog { $_[0]->{TABLE_CAT} }
sub schema  { $_[0]->{TABLE_SCHEM} }
sub type    { $_[0]->{TABLE_TYPE} }

1;

