package DBIx::Inspector::Driver::Base;
use strict;
use warnings;
use utf8;
use DBIx::Inspector::ForeignKey;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/dbh catalog schema driver/);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    bless {%args}, $class;
}

sub tables {
    my ($self, $table) = @_;

    my $sth = $self->{dbh}->table_info( $self->catalog, $self->schema, $table, my $type='TABLE' );

    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { DBIx::Inspector::Table->new(inspector => $self, %{$_[0]}) },
        sth =>$sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub table {
    my ($self, $table) = @_;
    Carp::croak("missing mandatory parameter: table") unless defined $table;
    return $self->tables($table)->next;
}

sub primary_key {
    my ($self, $table) = @_;

    my $sth = $self->dbh->primary_key_info( $self->catalog, $self->schema, $table );
    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub { DBIx::Inspector::Column->new(inspector => $self, %{$_[0]}) },
        sth =>$sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub columns {
    my ($self, $table, $column) = @_;
    $column = '%' if not defined $column;

    my $sth = $self->dbh->column_info( $self->catalog, $self->schema, $table, $column );
    my $iter = DBIx::Inspector::Iterator->new(
        callback =>
          sub { DBIx::Inspector::Column->new( table => $self, %{ $_[0] } ) },
        sth => $sth,
    );
    return wantarray ? $iter->all : $iter;
}

sub foreign_keys {
    my ($self, @args) = @_;

    my $sth = $self->inspector->dbh->foreign_key_info(@args);
    Carp::croak($self->inspector->dbh->errstr) unless $sth;
    my $iter = DBIx::Inspector::Iterator->new(
        callback => sub {
            DBIx::Inspector::ForeignKey->new( inspector => $self, %{ $_[0] } );
        },
        sth => $sth,
    );
    return wantarray ? $iter->all : $iter;
}

1;

