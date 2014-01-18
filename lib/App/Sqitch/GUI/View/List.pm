package App::Sqitch::GUI::View::List;

use Moose;
use namespace::autoclean;

use Wx qw(:everything);
use Wx::Event qw();
use Wx::Perl::ListCtrl;
with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);

extends 'Wx::Perl::ListCtrl';

has 'column_map' => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef[Str]',
    default => sub { {} },
    handles => {
        get_column => 'get',
        set_column => 'set',
    },
);

has column_count => (
    traits  => ['Counter'],
    is      => 'rw',
    isa     => 'Int',
    default => 0,
    handles => {
        inc_counter => 'inc',
    },
);

has 'count_col' => (
    is        => 'ro',
    isa       => 'Bool',
    required  => 1,
    default   => sub { 0 },
);

has 'count_col_label' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { '#' },
);

after 'BUILD' => sub {
    my $self = shift;
    if ( $self->count_col ) {
        my $label = $self->count_col_label;
        $self->add_column( $label, wxLIST_FORMAT_CENTER, 30, 'count_row' );
    }
    return;
};

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        [-1, -1],
        [-1, -1],
        Wx::wxLC_REPORT | Wx::wxLC_SINGLE_SEL,
    );
}

sub BUILD {
    my $self = shift;
    return $self;
};

sub add_column {
    my ( $self, @attr ) = @_;

    my $field = $attr[-1];
    my $index = $self->column_count;
    $self->set_column($field, $index);   # Store {field_name => index}
    pop @attr;                           # remove field_name
    unshift @attr, $index;               # add the index
    $self->InsertColumn(@attr);
    $self->inc_counter;

    return;
}

sub list_max_index {
    return ( shift->GetItemCount() - 1 );
}

sub get_list_item_text {
    my ($self, $item, $col) = @_;

    hurl __ 'Wrong arguments passed to get_list_item_text()'
        unless defined $item and defined $col;

    return $self->GetItemText($item, $col);
}

sub set_list_item_text {
    my ($self, $item, $col, $text) = @_;

    hurl __ 'Wrong arguments passed to set_list_item_text()'
        unless defined $item and defined $col and defined $text;

    return $self->SetItemText($item, $col, $text);
}

sub get_list_item_data {
    my ($self, $item) = @_;

    hurl __ 'Wrong arguments passed to get_list_item_data()'
        unless defined $item;

    return $self->GetItemData( $item );
}

sub set_list_item_data {
    my ($self, $item, $data) = @_;

    hurl __ 'Wrong arguments passed to set_list_item_data()'
        unless defined $item and ref $data;

    return $self->SetItemData( $item, $data );
}

sub select_item {
    my ( $self, $item ) = @_;

    hurl __ 'Wrong arguments passed to select_item()'
        unless defined $item;

    $self->Select( $item, 1 );    # 1|0 = select|deselect
    $self->EnsureVisible($item);
    return;
}

sub populate {
    my ($self, $record_ref, $index) = @_;

    my $has_count_col = $self->count_col // 0;
    my $row = $index // 0;                   # start at row
    foreach my $rec ( @{$record_ref} ) {
        $rec->{count_row} = $row + 1 if $has_count_col;
        $self->InsertStringItem( $row, 'dummy' );
        while ( my ( $field, $value ) = each( %{$rec} ) ) {
            my $col = $self->get_column($field);
            $self->set_list_item_text( $row, $col, $value );
        }
        $row++;
    }

    return;
}

sub _set_events { }

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

None known.

Please report any bugs or feature requests to the author.

=head1 ACKNOWLEDGMENTS

GUI with Wx and Moose heavily inspired/copied from the LacunaWaX
project:

https://github.com/tmtowtdi/LacunaWaX

Copyright: Jonathan D. Barton 2012-2013

Thank you!

=head1 LICENSE AND COPYRIGHT

  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::View::List
