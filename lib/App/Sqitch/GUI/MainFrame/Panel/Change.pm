package App::Sqitch::GUI::MainFrame::Panel::Change;

use utf8;
use Moose;
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::MainFrame::Notebook;
use App::Sqitch::GUI::MainFrame::Editor;

has 'panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'main_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'form_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'lbl_name'  => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_path'  => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_db'    => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_descr' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );

has 'txt_name'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'dpc_path'  => ( is => 'rw', isa => 'Wx::DirPickerCtrl', lazy_build => 1 );
has 'cho_db'    => ( is => 'rw', isa => 'Wx::Choice',   lazy_build => 1 );
has 'txt_descr' => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );

has 'sb_sizer'  => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'deploy_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'verify_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'revert_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'notebook' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::Notebook',
    lazy_build => 1,
);
has 'edit_deploy' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::Editor',
    lazy_build => 1,
);
has 'edit_revert' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::Editor',
    lazy_build => 1,
);
has 'edit_verify' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::Editor',
    lazy_build => 1,
);
has 'ed_deploy_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'ed_revert_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'ed_verify_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

sub BUILD {
    my $self = shift;

    $self->panel->Show(0);
    $self->panel->SetSizer( $self->sizer );

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->form_fg_sz, 1, wxEXPAND | wxALL, 5 );
    $self->main_fg_sz->Add( $self->notebook, 1, wxEXPAND | wxALL, 5 );

    #-- Top form

    $self->form_fg_sz->Add( $self->lbl_name, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_name, 0, wxLEFT, 2 );

    $self->form_fg_sz->Add( $self->lbl_db, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->cho_db, 0, wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_path, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->dpc_path, 0, wxLEFT, 0);

    $self->form_fg_sz->Add( $self->lbl_descr, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_descr, 1, wxEXPAND | wxLEFT, 2);

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

    $self->parent->Layout();

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

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 0, 1, 5 );
    $fgs->AddGrowableRow(1);
    $fgs->AddGrowableCol(0);
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 4, 0, 5, 10 );
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_lbl_name {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Name} );
}

sub _build_txt_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_lbl_path {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Path} );
}

sub _build_dpc_path {
    my $self = shift;

    my $dp = Wx::DirPickerCtrl->new(
        $self->panel, -1, q{},
        q{Choose a directory},
        [ -1, -1 ],
        [ -1, -1 ],
        # style
    );
    #EVT_DIRPICKER_CHANGED( $self, $dp, \&on_change );

    return $dp;
}

sub _build_lbl_db {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Database} );
}

sub _build_cho_db {
    my $self = shift;

    return Wx::Choice->new(
        $self->panel,
        -1,
        [ -1,  -1 ],
        [ 130, -1 ],
        [ 'PostgreSQL', 'MySQL', 'SQLite', 'CUBRID', 'Oracle' ],
        wxCB_SORT,
    );
}

sub _build_lbl_descr {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Description} );
}

sub _build_txt_descr {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ -1, -1 ] );
}

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

    return App::Sqitch::GUI::MainFrame::Notebook->new(
        app      => $self->app,
        parent   => $self->panel,
        ancestor => $self,
    );
}

sub _build_edit_deploy {
    my $self = shift;

    return App::Sqitch::GUI::MainFrame::Editor->new(
        app      => $self->app,
        parent   => $self->notebook->page_deploy,
        ancestor => $self,
    );
}

sub _build_edit_revert {
    my $self = shift;

    return App::Sqitch::GUI::MainFrame::Editor->new(
        app      => $self->app,
        parent   => $self->notebook->page_revert,
        ancestor => $self,
    );
}

sub _build_edit_verify {
    my $self = shift;

    return App::Sqitch::GUI::MainFrame::Editor->new(
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

sub _set_events { }

sub OnClose {
    my ($self, $event) = @_;
}

no Moose;
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

Thank you!

=head1 LICENSE AND COPYRIGHT

Copyright:
  Jonathan D. Barton 2012-2013
  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::Panel::Change
