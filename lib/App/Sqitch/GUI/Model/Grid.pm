package App::Sqitch::GUI::Model::Grid;

# ABSTRACT: Data Table Grid

use Moo;
use Types::Standard -types;
use List::Objects::Types -types;

use App::Sqitch::X qw(hurl);
use App::Sqitch::GUI::Model::Cell;

my $CellType
    = ( InstanceOf ['App::Sqitch::GUI::Model::Cell'] )
    ->plus_coercions(
        Str, sub { App::Sqitch::GUI::Model::Cell->new( name => $_ ) },
    );

has cells => (
    is      => 'rw',
    isa     => TypedArray [ TypedArray [$CellType] ],
    coerce  => 1,
    handles => {
        get_row    => 'get',
        set_row    => 'set',
        all_rows   => 'all',
        add_row    => 'push',
        remove_row => 'splice',
        rows_no    => 'count',
    },
);

sub get_cell {
    my $self = shift;
    my ( $row, $col ) = @_;
    if ( my $item = $self->get_row($row) ) {
        return $item->get($col);
    }
    else {
        hurl "Error, no such row: $row";
    }
}

sub set_cell {
    my $self = shift;
    my ($row, $col, $value) = @_;
    if ( my $item = $self->get_row($row) ) {
        $item->set($col, $value);
    }
    else {
        hurl "Error, no such row: $row";
    }
    return 1;
}

sub all_cells {
    my $self = shift;
    map { $_->all } $self->all_rows;
}

sub get_col {
    my $self = shift;
    my ($col) = @_;
    map { $_->get($col) } $self->all_rows;
}

sub set_col {
    my $self = shift;
    my ($col, $values) = @_;
    my @rows = $self->all_rows;
    unless (ref $values eq 'ARRAY') {
        my @col = ();
        push @col, $values for 0..$#rows;
        $values = \@col;
    }
    for my $i (0 .. $#rows) {
        $rows[$i]->set($col, $values->[$i]);
    }
    return 1;
}

sub add_col {
    my $self = shift;
    my ($values) = @_;
    my @rows = $self->all_rows;
    for my $i (0 .. $#rows) {
        $rows[$i]->push($values->[$i]);
    }
    return 1;
}

sub all_cols {
    my $self = shift;
    my $col_count   = $self->get_row(0)->count;
    my $return_type = TypedArray[$CellType];
    return
        map { $return_type->coerce($_) }
        map { [ $self->get_col($_) ] } 0 .. $col_count-1;
}

sub to_string {
    my $self = shift;
    join "\n", map(join("\t", map($_->name, $_->all)), $self->all_rows);
}

1;

__END__

=head1 ACKNOWLEDGMENTS

Code copied and adapted from http://www.perlmonks.org/?node_id=1052124

Thanks tobyink.

=cut
