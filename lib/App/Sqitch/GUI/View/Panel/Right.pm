package App::Sqitch::GUI::View::Panel::Right;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxPanel
    WxSizer
    WxButton
    WxRadioButton
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw(:allclasses :everything);
use Wx::Event qw<EVT_CLOSE>;

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

has 'panel_sbs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_panel_sbs',
);

has 'panel_fgs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_panel_fgs',
);

has 'commands_sbs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_commands_sbs',
);

has 'commands_fgs' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_commands_fgs',
);

has 'sizer_cmdtop' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sizer_cmdtop',
);

has 'sizer_cmdbot' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sizer_cmdbot',
);

has 'btn_status' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_status',
);

has 'btn_add' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_add',
);

has 'btn_deploy' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_deploy',
);

has 'btn_revert' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_revert',
);

has 'btn_verify' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_verify',
);

has 'btn_log' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_log',
);

has 'btn_quit' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_quit',
);

has 'btn_project' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_project',
);

has 'btn_project_sel' => (
    is      => 'rw',
    isa     => WxRadioButton,
    lazy    => 1,
    builder => '_build_btn_project_sel',
);

has 'btn_change' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_change',
);

has 'btn_change_sel' => (
    is      => 'rw',
    isa     => WxRadioButton,
    lazy    => 1,
    builder => '_build_btn_change_sel',
);

has 'btn_plan' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_plan',
);

has 'btn_plan_sel' => (
    is      => 'rw',
    isa     => WxRadioButton,
    lazy    => 1,
    builder => '_build_btn_plan_sel',
);

sub BUILD {
    my $self = shift;

    #-   The main panel

    $self->panel->Show(0);
    $self->panel->SetSizer( $self->sizer );

    #--- Panels

    $self->sizer->Add( $self->panel_sbs, 0, wxEXPAND | wxALL, 5 );
    $self->panel_sbs->Add( $self->panel_fgs,       0, wxEXPAND | wxALL, 5 );
    $self->panel_fgs->Add( $self->btn_project_sel, 0, wxEXPAND,         5 );
    $self->panel_fgs->Add( $self->btn_project,     0, wxEXPAND,         5 );
    $self->panel_fgs->Add( $self->btn_plan_sel,    0, wxEXPAND,         5 );
    $self->panel_fgs->Add( $self->btn_plan,        0, wxEXPAND,         5 );
    $self->panel_fgs->Add( $self->btn_change_sel,  0, wxEXPAND,         5 );
    $self->panel_fgs->Add( $self->btn_change,      0, wxEXPAND,         5 );

    #--- Commands

    $self->sizer->Add( $self->commands_sbs, 1, wxEXPAND | wxALL, 5 );
    $self->commands_sbs->Add( $self->sizer_cmdtop, 1, wxEXPAND | wxALL, 5 );
    $self->commands_sbs->Add( $self->sizer_cmdbot, 0, wxEXPAND | wxALL, 5 );
    $self->sizer_cmdtop->Add( $self->commands_fgs, 1, wxEXPAND | wxALL, 5 );
    $self->commands_fgs->Add( $self->btn_status,   1, wxEXPAND,         0 );
    $self->commands_fgs->Add( $self->btn_add,      1, wxEXPAND,         0 );
    $self->commands_fgs->Add( $self->btn_deploy,   1, wxEXPAND,         0 );
    $self->commands_fgs->Add( $self->btn_revert,   1, wxEXPAND,         0 );
    $self->commands_fgs->Add( $self->btn_verify,   1, wxEXPAND,         0 );
    $self->commands_fgs->Add( $self->btn_log,      1, wxEXPAND,         0 );
    $self->sizer_cmdbot->Add( $self->btn_quit,     1, wxALIGN_BOTTOM | wxALL, 5 );

    $self->panel->Show(1);

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
        'mainPanel',
    );
    #$panel->SetBackgroundColour(Wx::Colour->new('green'));

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_commands_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, ' Commands ', ),
        wxVERTICAL );
}

sub _build_panel_sbs {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, ' Select Panel ', ),
        wxVERTICAL );
}

sub _build_commands_fgs {
    my $fgsz = Wx::FlexGridSizer->new( 10, 0, 5, 0 ); # 10 rows for buttons
    $fgsz->AddGrowableCol( 0, 1 );
    return $fgsz;
}

sub _build_sizer_cmdtop {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_sizer_cmdbot {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_panel_fgs {
    return Wx::FlexGridSizer->new( 3, 2, 5, 0 ); # 3 rows for buttons
}

sub _build_btn_status {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Status},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_add {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Add},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_deploy {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Deploy},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_revert {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Revert},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_verify {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Verify},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_log {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Log},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_quit {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        __ '&Quit',
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_change_sel {
    my $self = shift;

    return Wx::RadioButton->new(
        $self->panel,
        -1,
        q{« },
        [-1, -1],
        [-1, -1],
    );
}

sub _build_btn_change {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Change},
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_btn_project_sel {
    my $self = shift;

    return Wx::RadioButton->new(
        $self->panel,
        -1,
        q{« },
        [-1, -1],
        [-1, -1],
    );
}

sub _build_btn_project {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Project},
        [ -1, -1 ],
        [ -1, -1 ],
        wxRB_GROUP,             # first button in group
    );
}

sub _build_btn_plan_sel {
    my $self = shift;

    return Wx::RadioButton->new(
        $self->panel,
        -1,
        q{« },
        [-1, -1],
        [-1, -1],
    );
}

sub _build_btn_plan {
    my $self = shift;

    return Wx::Button->new(
        $self->panel,
        -1,
        q{Plan},
        [ -1, -1 ],
        [ -1, -1 ],
    );
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

  Stefan Suciu 2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::View::Panel::Right
