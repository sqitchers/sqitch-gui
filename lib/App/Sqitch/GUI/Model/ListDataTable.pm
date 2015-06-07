package App::Sqitch::GUI::Model::ListDataTable;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use Types::Standard qw(ArrayRef Int);

has 'list_data' => (
    is      => 'rw',
    isa     => ArrayRef[ArrayRef],
    default => sub { [ [] ] },
);

has 'default' => (
    is      => 'rw',
    isa     => Int,
    default => sub { 0 },
);

sub set_value {
    my ($self, $row, $col, $value) = @_;
    $self->list_data->[$row][$col] = $value;
    return;
}

sub get_value {
    my ($self, $row, $col) = @_;
    return $self->list_data->[$row][$col];
}

sub get_data {
    my $self = shift;
    return $self->list_data;
}

sub get_item_count {
    my $self = shift;
    return scalar @{ $self->get_data };
}

1;
