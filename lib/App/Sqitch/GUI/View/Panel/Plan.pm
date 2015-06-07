package App::Sqitch::GUI::View::Panel::Plan;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxPanel
    WxSizer
    SqitchGUIWxListctrl
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

use App::Sqitch::GUI::Model::ListDataTable;
use App::Sqitch::GUI::Wx::Listctrl;

with 'App::Sqitch::GUI::Roles::Element';

has 'panel' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_panel',
);

has 'sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sizer',
);

has 'btn_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_btn_sizer',
);

has 'sb_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sb_sizer',
);

has 'main_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_main_fg_sz',
);

has 'list_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_list_fg_sz',
);

has 'list_ctrl' => (
    is      => 'rw',
    isa     => SqitchGUIWxListctrl,
    lazy    => 1,
    builder => '_build_list_ctrl',
);

has 'list_data' => (
    is      => 'ro',
    default => sub {
        return App::Sqitch::GUI::Model::ListDataTable->new;
    },
);

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 5 );

    #-- List

    $self->list_fg_sz->Add( $self->list_ctrl, 1, wxEXPAND, 3 );

    $self->panel->SetSizer($self->sizer);

    return $self;
}

sub _build_panel {
    my $self = shift;

    my $panel = Wx::Panel->new(
        $self->parent,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxFULL_REPAINT_ON_RESIZE,
        'projectPanel',
    );
    #$panel->SetBackgroundColour( Wx::Colour->new('blue') );

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 1, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 1, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_sb_sizer {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, __ 'Plan ', ), wxVERTICAL );
}

sub _build_list_ctrl {
    my $self = shift;
    my $list_ctrl = App::Sqitch::GUI::Wx::Listctrl->new(
        app       => $self->app,
        parent    => $self->panel,
        list_data => $self->list_data,
        meta_data => $self->list_meta_data,
    );
    return $list_ctrl;
}

sub _set_events { }

sub OnClose {
    my ($self, $event) = @_;
}

sub list_meta_data {
    return [
        {   field => 'recno',
            label => '#',
            align => 'center',
            width => 25,
            type  => 'int',
        },
        {   field => 'name',
            label => __ 'Name',
            align => 'left',
            width => 100,
            type  => 'str',
        },
        {   field => 'create_time',
            label => __ 'Create time',
            align => 'left',
            width => 150,
            type  => 'str',
        },
        {   field => 'creator',
            label => __ 'Creator',
            align => 'center',
            width => 110,
            type  => 'str',
        },
        {   field => 'description',
            label => __ 'Description',
            align => 'left',
            width => 225,
            type  => 'str',
        },
    ];
}

sub populate {
    my ($self, $record_ref) = @_;

    my $data_table = $self->list_data;
    my $cols_meta  = $self->list_meta_data;
    my $row        = ( $data_table->get_item_count // 1 ) - 1;
    foreach my $rec ( @{$record_ref} ) {
        my $col = 0;
        foreach my $meta ( @{$cols_meta} ) {
            my $field = $meta->{field};
            my $value
                = $field eq q{}     ? q{}
                : $field eq 'recno' ? ( $row + 1 )
                :                     ( $rec->{$field} // q{} );
            $data_table->set_value( $row, $col, $value );
            $col++;
        }
        $self->list_ctrl->RefreshList;
        $row++;
    }
    return;
}

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

1;    # End of App::Sqitch::GUI::Panel::Plan
