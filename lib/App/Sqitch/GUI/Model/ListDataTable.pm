package App::Sqitch::GUI::Model::ListDataTable;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use Types::Standard qw(
    ArrayRef
    Int
);
use App::Sqitch::X qw(hurl);

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
    hurl 'Wrong arguments passed to set_value()'
        unless defined $row and defined $col;
    return $self->list_data->[$row][$col] = $value;
}

sub get_value {
    my ($self, $row, $col) = @_;
    hurl 'Wrong arguments passed to get_value()'
        unless defined $row and defined $col;
    return $self->list_data->[$row][$col];
}

sub get_data {
    my $self = shift;
    return $self->list_data;
}

sub get_item_count {
    my $self = shift;
    my @table_data = @{ $self->get_data };
    return 0
        unless grep { defined $_->[0] }
        @table_data;    # case of: [[]] when scalar @table_data == 1, not 0
    return scalar @table_data;
}

1;
