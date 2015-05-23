package App::Sqitch::GUI::ListCtrl;

# ABSTRACT: Virtual List View Control

use 5.010;
use strict;
use warnings;
use Moo;
use Types::Standard qw(ArrayRef);
use Wx qw(
    wxLC_REPORT
    wxLC_SINGLE_SEL
    wxLC_VIRTUAL
    wxLIST_FORMAT_CENTER
    wxLIST_FORMAT_LEFT
    wxLIST_FORMAT_RIGHT
);
use Wx qw(:listctrl);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);

extends 'Wx::ListView';

has 'list_data' => (
    is  => 'rw',
);

has 'meta_data' => (
    is  => 'rw',
);

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxLC_REPORT | wxLC_VIRTUAL | wxLC_SINGLE_SEL
    );
}

sub BUILD {
    my $self = shift;
    $self->add_columns( $self->meta_data );
    return $self;
}

sub add_columns {
    my ( $self, $header ) = @_;
    my $cnt = 0;
    foreach my $rec ( @{$header} ) {
        my $label = $rec->{label};
        my $width = $rec->{width};
        my $align
            = $rec->{align} eq 'left'   ? wxLIST_FORMAT_LEFT
            : $rec->{align} eq 'center' ? wxLIST_FORMAT_CENTER
            : $rec->{align} eq 'right'  ? wxLIST_FORMAT_RIGHT
            :                             wxLIST_FORMAT_LEFT;
        $self->InsertColumn( $cnt, $label, $align, $width );
        $cnt++;
    }
    return;
}

sub OnGetItemText {
    my( $self, $item, $column ) = @_;
    return $self->list_data->get_value( $item, $column );
}

sub OnGetItemAttr {
    my( $self, $item ) = @_;
    my $attr = Wx::ListItemAttr->new;
    $attr->SetBackgroundColour( Wx::Colour->new('LIGHT YELLOW') )
        if $item % 2 == 0;
    return $attr;
}

sub RefreshList {
    my $self = shift;
    my $item_count = $self->list_data->get_item_count;
    $self->SetItemCount( $item_count );
    $self->RefreshItems(0, $item_count);
    return;
}

sub set_selection {
    my ( $self, $item ) = @_;
    $self->Select( $item, 1 );               # 1|0 <=> select|deselect
    return;
}

sub get_selection {
    my $self = shift;
    return $self->GetFirstSelected;
}

sub _set_events { }

1;
