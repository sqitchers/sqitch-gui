package App::Sqitch::GUI::Model::ListDataTable;

# ABSTRACT: List Data Table

use 5.010;
use utf8;
use Moo;
use Try::Tiny;
use App::Sqitch::GUI::Types qw(
    Int
);

use App::Sqitch::X qw(hurl);
use App::Sqitch::GUI::Model::Grid;

has 'list_data' => (
    is      => 'rw',
    default => sub {
        my $grid = App::Sqitch::GUI::Model::Grid->new( cells => [] );
    },
);

has 'default' => (
    is      => 'rw',
    isa     => Int,
    default => sub { 0 },
);

sub set_value {
    my $self = shift;
    my ($row, $col, $value) = @_;
    hurl 'Wrong arguments passed to set_value()'
        unless defined $row and defined $col;
    $self->list_data->set_cell($row, $col, $value);
    return 1;
}

sub get_value {
    my $self = shift;
    my ($row, $col) = @_;
    hurl 'Wrong arguments passed to get_value()'
        unless defined $row and defined $col;
    return $self->list_data->get_cell($row, $col)->name;
    # for DEBUG?
    # my $value = try { $self->list_data->get_cell($row, $col)->name }
    # catch {
    #     warn "'$_'\n";
    # };
}

sub get_data_as_string {
    my $self = shift;
    return $self->list_data->to_string;
}

sub remove_row {
    my $self = shift;
    my ($item, $count) = @_;
    $count //= 1;
    return $self->list_data->remove_row($item, $count);
}

sub get_item_count {
    my $self = shift;
    return $self->list_data->rows_no;
}

sub add_row {
    my $self = shift;
    $self->list_data->add_row(\@_);
}

sub get_col {
    my $self = shift;
    my ($col) = @_;
    return $self->list_data->get_col($col);
}

sub set_col {
    my $self = shift;
    my ($col, $value) = @_;
    return $self->list_data->set_col($col, $value);
}

1;
