package App::Sqitch::GUI::MainFrame::MainPanel;

use Moose;
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::MainFrame::Notebook;
use App::Sqitch::GUI::MainFrame::Editor;

has 'main_panel'   => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'main_sizer'   => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'left_sizer'   => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'main_sbs'     => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'top_sizer'    => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'log_sbs'      => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'bottom_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'right_sizer'  => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'commands_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'commands_fgs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'notebook'     => (
    is  => 'rw',
    isa => 'App::Sqitch::GUI::MainFrame::Notebook',
    lazy_build => 1,
);
has 'edit_deploy' => (
    is  => 'rw',
    isa => 'App::Sqitch::GUI::MainFrame::Editor',
    lazy_build => 1,
);
has 'edit_revert' => (
    is  => 'rw',
    isa => 'App::Sqitch::GUI::MainFrame::Editor',
    lazy_build => 1,
);
has 'edit_verify' => (
    is  => 'rw',
    isa => 'App::Sqitch::GUI::MainFrame::Editor',
    lazy_build => 1,
);
has 'ed_deploy_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1);
has 'ed_revert_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1);
has 'ed_verify_sbs' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1);
has 'btn_deploy'  => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_revert'  => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_verify'  => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );

sub BUILD {
    my $self = shift;

    #-   The main panel

    $self->main_panel->Show(0);
    $self->main_panel->SetSizer( $self->main_sizer );

    $self->main_sizer->Add( $self->left_sizer,  1, wxEXPAND, 5 );
    $self->main_sizer->Add( $self->right_sizer, 0, wxEXPAND, 5 );

    $self->left_sizer->Add( $self->main_sbs, 1, wxEXPAND, 5 );

    #--  Notebook on the left-top side for SQL edit

    $self->main_sbs->Add( $self->top_sizer, 1, wxEXPAND, 5 );
    $self->top_sizer->Add( $self->notebook, 1, wxEXPAND | wxALL, 5 );

    #--- Page Deploy

    my $sql_deploy_sz = Wx::BoxSizer->new(wxVERTICAL);
    $self->ed_deploy_sbs->Add($self->edit_deploy, 1, wxEXPAND | wxALL, 5 );
    $sql_deploy_sz->Add( $self->ed_deploy_sbs, 1, wxEXPAND | wxALL, 5 );
    $self->notebook->page_deploy->SetSizer( $sql_deploy_sz );

    #--- Page Deploy

    my $sql_revert_sz = Wx::BoxSizer->new(wxVERTICAL);
    $self->ed_revert_sbs->Add($self->edit_revert, 1, wxEXPAND | wxALL, 5 );
    $sql_revert_sz->Add( $self->ed_revert_sbs, 1, wxEXPAND | wxALL, 5 );
    $self->notebook->page_revert->SetSizer( $sql_revert_sz );

    #--- Page Verify

    my $sql_verify_sz = Wx::BoxSizer->new(wxVERTICAL);
    $self->ed_verify_sbs->Add( $self->edit_verify, 1, wxEXPAND | wxALL, 5 );
    $sql_verify_sz->Add( $self->ed_verify_sbs, 1, wxEXPAND | wxALL, 5 );
    $self->notebook->page_verify->SetSizer($sql_verify_sz);

    #--  Log control on the left-bottom side

    $self->left_sizer->Add( $self->log_sbs, 1, wxEXPAND, 5 );
    $self->log_sbs->Add( $self->bottom_sizer, 1, wxEXPAND, 5 );

    #--  Command buttons on the right side

    $self->right_sizer->Add( $self->commands_sbs, 1, wxEXPAND, 0 );
    $self->commands_sbs->Add( $self->commands_fgs, 0, wxEXPAND | wxALL, 5 );
    $self->commands_fgs->AddSpacer(10);
    $self->commands_fgs->Add($self->btn_deploy, 0, wxEXPAND, 5);
    $self->commands_fgs->Add($self->btn_revert, 0, wxEXPAND, 5);
    $self->commands_fgs->Add($self->btn_verify, 0, wxEXPAND, 5);

    $self->main_panel->Show(1);

    return $self;
}

sub _build_main_panel {
    my $self = shift;

    my $panel = Wx::Panel->new(
        $self->parent,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxFULL_REPAINT_ON_RESIZE,
        'mainPanel',
    );
    #$panel->SetBackgroundColour(Wx::Colour->new(150,150,150));

    return $panel;
}

sub _build_test_panel {
    my $self = shift;

    my $panel = Wx::Panel->new(
        $self->parent,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxFULL_REPAINT_ON_RESIZE,
        'testPanel',
    );
    $panel->SetBackgroundColour(Wx::Colour->new(200,0,0));

    return $panel;
}

sub _build_main_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_left_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_main_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->main_panel, -1, ' Main ', ), wxHORIZONTAL );
}

sub _build_top_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_log_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->main_panel, -1, ' Log ', ), wxHORIZONTAL );
}

sub _build_bottom_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_right_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_commands_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->main_panel, -1, ' Commands ', ),
        wxHORIZONTAL );
}

sub _build_commands_fgs {
    return Wx::FlexGridSizer->new( 10, 0, 5, 0 ); # 10 rows for buttons
}

sub _build_notebook {
    my $self = shift;

    return App::Sqitch::GUI::MainFrame::Notebook->new(
        app      => $self->app,
        parent   => $self->parent,
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
            -1, ' SQL View | Edit ',
        ),
        wxHORIZONTAL
    );
}

sub _build_ed_revert_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new(
            $self->notebook->page_revert,
            -1, ' SQL View | Edit ',
        ),
        wxHORIZONTAL
    );
}

sub _build_ed_verify_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new(
            $self->notebook->page_verify,
            -1, ' SQL View | Edit ',
        ),
        wxHORIZONTAL
    );
}

# sub nb_deploy_sizer {
#     return Wx::BoxSizer->new(wxHORIZONTAL);
# }

sub _build_btn_deploy {
    my $self = shift;

    return Wx::Button->new(
        $self->main_panel,
        -1,
        q{Deploy},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_revert {
    my $self = shift;

    return Wx::Button->new(
        $self->main_panel,
        -1,
        q{Revert},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_verify {
    my $self = shift;

    return Wx::Button->new(
        $self->main_panel,
        -1,
        q{Verify},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _set_events { }

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

1;    # End of App::Sqitch::GUI::MainPanel
