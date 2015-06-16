package App::Sqitch::GUI::View::Panel::Change;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    SqitchGUIWxEditor
    SqitchGUIWxNotebook
    WxCollapsiblePane
    WxPanel
    WxSizer
    WxStaticText
    WxTextCtrl
);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE EVT_COLLAPSIBLEPANE_CHANGED);

with qw(App::Sqitch::GUI::Roles::Element
        App::Sqitch::GUI::Roles::Panel);

use App::Sqitch::GUI::Wx::Notebook;
use App::Sqitch::GUI::Wx::Editor;

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

has 'top_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_top_sizer',
);

has 'colpsizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_colpsizer',
);

has 'collpane' => (
    is      => 'rw',
    isa     => WxCollapsiblePane,
    lazy    => 1,
    builder => '_build_collpane',
);

has 'main_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_main_fg_sz',
);

has 'form_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_form_fg_sz',
);

has 'lbl_change_id' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_change_id',
);

has 'lbl_name' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_name',
);

has 'lbl_note' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_note',
);

has 'lbl_committed_at' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_committed_at',
);

has 'lbl_committer_name' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_committer_name',
);

has 'lbl_committer_email' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_committer_email',
);

has 'lbl_planned_at' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_planned_at',
);

has 'lbl_planner_name' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_planner_name',
);

has 'lbl_planner_email' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_planner_email',
);

has 'txt_change_id' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_change_id',
);

has 'txt_name' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_name',
);

has 'txt_note' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_note',
);

has 'txt_committed_at' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_committed_at',
);

has 'txt_committer_name' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_committer_name',
);

has 'txt_committer_email' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_committer_email',
);

has 'txt_planned_at' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_planned_at',
);

has 'txt_planner_name' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_planner_name',
);

has 'txt_planner_email' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_planner_email',
);

has 'sb_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sb_sizer',
);

has 'deploy_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_deploy_sz',
);

has 'verify_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_verify_sz',
);

has 'revert_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_revert_sz',
);

has 'notebook' => (
    is      => 'rw',
    isa     => SqitchGUIWxNotebook,
    lazy    => 1,
    builder => '_build_notebook',
);
has 'edit_deploy' => (
    is      => 'rw',
    isa     => SqitchGUIWxEditor,
    lazy    => 1,
    builder => '_build_edit_deploy',
);

has 'edit_revert' => (
    is      => 'rw',
    isa     => SqitchGUIWxEditor,
    lazy    => 1,
    builder => '_build_edit_revert',
);

has 'edit_verify' => (
    is      => 'rw',
    isa     => SqitchGUIWxEditor,
    lazy    => 1,
    builder => '_build_edit_verify',
);

has 'ed_deploy_sbs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_ed_deploy_sbs',
);

has 'ed_revert_sbs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_ed_revert_sbs',
);

has 'ed_verify_sbs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_ed_verify_sbs',
);

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );
    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->top_sizer, 1, wxEXPAND | wxALL, 5 );
    $self->main_fg_sz->Add( $self->notebook, 1, wxEXPAND | wxALL, 5 );

    $self->top_sizer->Add($self->collpane, 1, wxEXPAND | wxALL, 5); # 0 prop!
    #$self->collpane->GetPane->SetBackgroundColour( Wx::Colour->new('red') );

    #-- Top form
    $self->colpsizer->Add(-1, 15);           # vspace
    $self->colpsizer->Add($self->form_fg_sz, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_change_id, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_change_id, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_name, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_name, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_note, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_note, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_planned_at, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_planned_at, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_planner_name, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_planner_name, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_planner_email, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_planner_email, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_committed_at, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_committed_at, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_committer_name, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_committer_name, 1, wxEXPAND | wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_committer_email, 0, wxLEFT, 0);
    $self->form_fg_sz->Add( $self->txt_committer_email, 1, wxEXPAND | wxLEFT, 0);
    $self->collpane->GetPane->SetSizer($self->colpsizer);

    #--  Notebook on the bottom side for SQL edit
    #--- Page Deploy

    $self->notebook->page_deploy->SetSizer( $self->deploy_sz );
    $self->ed_deploy_sbs->Add($self->edit_deploy, 1, wxEXPAND | wxALL, 5 );
    $self->deploy_sz->Add( $self->ed_deploy_sbs, 1, wxEXPAND | wxALL, 5 );

    #--- Page Revert

    $self->notebook->page_revert->SetSizer( $self->revert_sz );
    $self->ed_revert_sbs->Add($self->edit_revert, 1, wxEXPAND | wxALL, 5 );
    $self->revert_sz->Add( $self->ed_revert_sbs, 1, wxEXPAND | wxALL, 5 );

    #--- Page Verify

    $self->notebook->page_verify->SetSizer($self->verify_sz);
    $self->ed_verify_sbs->Add( $self->edit_verify, 1, wxEXPAND | wxALL, 5 );
    $self->verify_sz->Add( $self->ed_verify_sbs, 1, wxEXPAND | wxALL, 5 );

    $self->panel->SetSizer( $self->sizer );

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
        'changePanel',
    );
    #$panel->SetBackgroundColour(Wx::Colour->new('red'));

    return $panel;
}

sub _build_collpane {
    my $self = shift;

    my $pane = Wx::CollapsiblePane->new(
        $self->panel,
        -1,
        'Details',
        [-1,-1],
        [-1,-1],
        wxCP_DEFAULT_STYLE | wxCP_NO_TLW_RESIZE,
    );

    return $pane;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_top_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_colpsizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 1, 1, 5 );
    $fgs->AddGrowableRow(1);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 9, 2, 5, 10 );
    $fgs->AddGrowableRow(1);
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_lbl_change_id {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Change Id} );
}

sub _build_lbl_name {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Name} );
}

sub _build_lbl_note {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Note} );
}

sub _build_lbl_committed_at {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Commited at} );
}

sub _build_lbl_committer_name {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Commiter name} );
}

sub _build_lbl_committer_email {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Commiter email} );
}

sub _build_lbl_planned_at {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Planned at} );
}

sub _build_lbl_planner_name {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Planner name} );
}

sub _build_lbl_planner_email {
    my $self = shift;
    return Wx::StaticText->new( $self->collpane->GetPane, -1, q{Planner email} );
}

sub _build_txt_change_id {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_note{
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_committed_at {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_committer_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_committer_email {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_planned_at {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_planner_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_planner_email {
    my $self = shift;
    return Wx::TextCtrl->new( $self->collpane->GetPane, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

#--

sub _build_deploy_sz {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_verify_sz {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_revert_sz {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_sb_sizer {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, ' Change ', ), wxHORIZONTAL );
}

sub _build_notebook {
    my $self = shift;

    return App::Sqitch::GUI::Wx::Notebook->new(
        app      => $self->app,
        parent   => $self->panel,
        ancestor => $self,
    );
}

sub _build_edit_deploy {
    my $self = shift;

    return App::Sqitch::GUI::Wx::Editor->new(
        app      => $self->app,
        parent   => $self->notebook->page_deploy,
        ancestor => $self,
    );
}

sub _build_edit_revert {
    my $self = shift;

    return App::Sqitch::GUI::Wx::Editor->new(
        app      => $self->app,
        parent   => $self->notebook->page_revert,
        ancestor => $self,
    );
}

sub _build_edit_verify {
    my $self = shift;

    return App::Sqitch::GUI::Wx::Editor->new(
        app      => $self->app,
        parent   => $self->notebook->page_verify,
        ancestor => $self,
    );
}

sub _build_ed_deploy_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new(
            $self->notebook->page_deploy,
            -1, ' View | Edit ',
        ),
        wxHORIZONTAL
    );
}

sub _build_ed_revert_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new(
            $self->notebook->page_revert,
            -1, ' View | Edit ',
        ),
        wxHORIZONTAL
    );
}

sub _build_ed_verify_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new(
            $self->notebook->page_verify,
            -1, ' View | Edit ',
        ),
        wxHORIZONTAL
    );
}

sub _set_events {
    my ($self, $event) = @_;

    EVT_COLLAPSIBLEPANE_CHANGED $self->parent, $self->collpane,
        sub { $self->OnPaneChanged(@_); };

    return;
}

sub OnPaneChanged {
    my ($self, $frame, $event) = @_;
    $frame->Layout();
}

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

  Stefan Suciu 2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::Panel::Change
