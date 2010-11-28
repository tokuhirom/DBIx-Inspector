package DBIx::Inspector::Iterator;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/sth callback skip_cb/);

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless {%args}, $class;
}

sub next {
    my $self = shift;

    if (my $row = $self->sth->fetchrow_hashref()) {
        if ($self->skip_cb && $self->skip_cb->($row)) {
            return $self->next();
        }
        $self->callback->($row);
    } else {
        return;
    }
}

sub all {
    my $self = shift;
    my @rows;
    while (my $row = $self->next) {
        push @rows, $row;
    }
    return @rows;
}

1;

