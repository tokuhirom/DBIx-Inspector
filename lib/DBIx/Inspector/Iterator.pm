package DBIx::Inspector::Iterator;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/sth callback/);

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless {%args}, $class;
}

sub next {
    my $self = shift;

    if (my $row = $self->sth->fetchrow_hashref()) {
        $self->callback->($row);
    } else {
        return;
    }
}

sub first {
    my $self = shift;
    $self->next;
}

sub all {
    my $self = shift;
    my @rows;
    while (my $row = $self->next) {
        push @rows, $row;
    }
    return wantarray ? @rows : \@rows;
}

1;

