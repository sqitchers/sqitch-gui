package App::Sqitch::GUI::View::Panel::Plan;

# ABSTRACT: The Plan Panel

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxButton
    WxPanel
    WxSizer
    SqitchGUIWxListctrl
    SqitchGUIModelListDataTable
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

use App::Sqitch::GUI::Wx::Listctrl;

with 'App::Sqitch::GUI::Roles::Element';

has 'panel' => (
    is      => 'ro',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_panel',
);

has 'sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sizer',
);

has 'btn_sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_btn_sizer',
);

has 'sb_sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sb_sizer',
);

has 'main_fg_sz' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_main_fg_sz',
);

has 'list_fg_sz' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_list_fg_sz',
);

has 'list_ctrl' => (
    is      => 'ro',
    isa     => SqitchGUIWxListctrl,
    lazy    => 1,
    builder => '_build_list_ctrl',
);

has 'btn_load' => (
    is      => 'ro',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_load',
);

sub _build_list_ctrl {
    my $self = shift;
    my $list_ctrl = App::Sqitch::GUI::Wx::Listctrl->new(
        app       => $self->app,
        parent    => $self->panel,
        list_data => $self->app->model->plan_list_data,
        meta_data => $self->app->model->plan_list_meta_data,
    );
    return $list_ctrl;
}

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 5 );

    #-- List

    $self->list_fg_sz->Add( $self->list_ctrl, 1, wxEXPAND, 3 );

    $self->panel->SetSizer($self->sizer);

    #-- Button

    $self->btn_sizer->Add( $self->btn_load, 1, wxLEFT | wxRIGHT | wxEXPAND, 25 );
    $self->main_fg_sz->Add( $self->btn_sizer, 1, wxALIGN_CENTRE);

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

sub _build_btn_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

#-- Buttons

sub _build_btn_load {
    my $self = shift;

    my $button = Wx::Button->new(
        $self->panel,
        -1,
        __ 'Load',
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(1);

    return $button;
}

sub _set_events { }

sub OnClose {
    my ($self, $event) = @_;
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
