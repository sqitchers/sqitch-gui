package App::Sqitch::GUI::View::Panel::Project;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxButton
    WxPanel
    WxSizer
    WxStaticLine
    WxTextCtrl
    WxStaticText
    SqitchGUIListCtrl
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

use App::Sqitch::GUI::ListDataTable;
use App::Sqitch::GUI::ListCtrl;

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

has 'form_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_form_fg_sz',
);

has 'subform1_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_subform1_fg_sz',
);

has 'subform2_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_subform2_fg_sz',
);

has 'list_ctrl' => (
    is      => 'rw',
    isa     => SqitchGUIListCtrl,
    lazy    => 1,
    builder => '_build_list_ctrl',
);

has 'list_data' => (
    is      => 'ro',
    default => sub {
        return App::Sqitch::GUI::ListDataTable->new;
    },
);

has 'h_line1' => (
    is      => 'rw',
    isa     => WxStaticLine,
    lazy    => 1,
    builder => '_build_h_line1',
);

has 'btn_load' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_load',
);

has 'btn_default' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_default',
);

has 'btn_add' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_add',
);

has 'lbl_project' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_project',
);

has 'lbl_database' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_database',
);

has 'lbl_user' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_user',
);

has 'lbl_uri' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_uri',
);

has 'lbl_created_at' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_created_at',
);

has 'lbl_creator_name' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_creator_name',
);

has 'lbl_creator_email' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_creator_email',
);

has 'lbl_path' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_path',
);

has 'lbl_engine' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_engine',
);

has 'txt_project' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_project',
);

has 'txt_database' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_database',
);

has 'txt_user' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_user',
);

has 'txt_uri' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_uri',
);

has 'txt_created_at' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_created_at',
);

has 'txt_creator_name' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_creator_name',
);

has 'txt_creator_email' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_creator_email',
);

has 'txt_path' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_path',
);

has 'txt_engine' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_engine',
);

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->form_fg_sz, 1, wxEXPAND | wxALL, 5 );
    $self->main_fg_sz->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 5 );

    #-- Top form

    $self->form_fg_sz->Add( $self->lbl_project, 0, wxLEFT, 5 );
    $self->subform1_fg_sz->Add( $self->txt_project, 1, wxLEFT, 0 );
    $self->subform1_fg_sz->Add( $self->lbl_engine, 0, wxLEFT, 50 );
    $self->subform1_fg_sz->Add( $self->txt_engine, 0, wxLEFT, 20 );
    $self->form_fg_sz->Add( $self->subform1_fg_sz, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_database, 0, wxLEFT, 5 );
    $self->subform2_fg_sz->Add( $self->txt_database, 1, wxLEFT, 0 );
    $self->subform2_fg_sz->Add( $self->lbl_user, 0, wxLEFT, 53 );
    $self->subform2_fg_sz->Add( $self->txt_user, 1, wxEXPAND | wxLEFT, 20 );
    $self->form_fg_sz->Add( $self->subform2_fg_sz, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_path, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_path, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_uri, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_uri, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_created_at, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_created_at, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_creator_name, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_creator_name, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_creator_email, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_creator_email, 1, wxEXPAND | wxLEFT, 0 );

    #-- List and buttons

    $self->list_fg_sz->Add( $self->list_ctrl, 1, wxEXPAND, 3 );

    $self->list_fg_sz->Add( $self->h_line1, 1, wxEXPAND | wxTOP | wxBOTTOM,
        10 );
    $self->btn_sizer->Add( $self->btn_load, 1, wxLEFT | wxRIGHT | wxEXPAND,
        25 );
    $self->btn_sizer->Add( $self->btn_default, 1,
        wxLEFT | wxRIGHT | wxEXPAND, 25 );
    $self->btn_sizer->Add( $self->btn_add, 1, wxLEFT | wxRIGHT | wxEXPAND,
        25 );

    $self->list_fg_sz->Add( $self->btn_sizer, 1, wxALIGN_CENTRE);

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
    #$panel->SetBackgroundColour( Wx::Colour->new('green') );

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_btn_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 1, 1, 5 );
    $fgs->AddGrowableRow(1);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

#-  Form

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 7, 2, 6, 10 );
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_subform1_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 3, 0, 0 );
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_subform2_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 3, 0, 0 );
    $fgs->AddGrowableCol(0);
    return $fgs;
}

#-- Labels

sub _build_lbl_project {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Project' );
}

sub _build_lbl_database {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Database' );
}

sub _build_lbl_user {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'User' );
}

sub _build_lbl_uri {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'URI' );
}

sub _build_lbl_created_at {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Created at' );
}

sub _build_lbl_creator_name {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Creator name' );
}

sub _build_lbl_creator_email {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Creator email' );
}

sub _build_lbl_engine {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Engine' );
}

sub _build_lbl_path {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, __ 'Repository' );
}

#-- Entry

sub _build_txt_project {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_database {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_user {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_uri {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_created_at {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_creator_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_creator_email {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_path {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_engine {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

#-  List and buttons

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 1, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_sb_sizer {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, __ 'Project', ), wxVERTICAL );
}

#-- Lines

sub _build_h_line1 {
    my $self = shift;
    return Wx::StaticLine->new(
        $self->panel,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_load {
    my $self = shift;

    my $button = Wx::Button->new(
        $self->panel,
        -1,
        __ 'Load',
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_btn_default {
    my $self = shift;

    my $button = Wx::Button->new(
        $self->panel,
        -1,
        __ 'Default',
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_btn_add {
    my $self = shift;

    my $button = Wx::Button->new(
        $self->panel,
        -1,
        __ 'Add',
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_list_ctrl {
    my $self = shift;
    my $list_ctrl = App::Sqitch::GUI::ListCtrl->new(
        app       => $self->app,
        parent    => $self->panel,
        list_data => $self->list_data,
        meta_data => $self->list_meta_data,
    );
    return $list_ctrl;
}

sub _set_events {
    my ($self, $event) = @_;
    return;
}

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
        {   field => 'project',
            label => __ 'Project',
            align => 'left',
            width => 100,
            type  => 'str',
        },
        {   field => 'database',
            label => __ 'Database',
            align => 'left',
            width => 60,
            type  => 'str',
        },
        {   field => 'default',
            label => __ 'Default',
            align => 'center',
            width => 60,
            type  => 'bool',
        },
        {   field => 'description',
            label => __ 'Description',
            align => 'left',
            width => 320,
            type  => 'str',
        },
    ];
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

1;    # End of App::Sqitch::GUI::Panel::Project
