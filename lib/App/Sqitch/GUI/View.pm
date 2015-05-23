package App::Sqitch::GUI::View;

use 5.010;
use strict;
use warnings;
use Moo;
use App::Sqitch::GUI::Types qw(
    ArrayRef
    Int
    Maybe
    SqitchGUIViewMenuBar
    SqitchGUIViewMenuBarAdmin
    SqitchGUIViewMenuBarApp
    SqitchGUIViewMenuBarHelp
    SqitchGUIViewPanelBottom
    SqitchGUIViewPanelChange
    SqitchGUIViewPanelLeft
    SqitchGUIViewPanelPlan
    SqitchGUIViewPanelProject
    SqitchGUIViewPanelRight
    SqitchGUIViewPanelTop
    SqitchGUIViewStatusBar
    Str
    WxFrame
    WxPoint
    WxSize
    WxSizer
    WxSplitterWindow
    WxStatusBar
);
use Wx qw(:everything);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON EVT_MENU EVT_RADIOBUTTON);

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::View::MenuBar;
use App::Sqitch::GUI::View::StatusBar;
use App::Sqitch::GUI::View::Panel::Left;
use App::Sqitch::GUI::View::Panel::Right;
use App::Sqitch::GUI::View::Panel::Top;
use App::Sqitch::GUI::View::Panel::Bottom;

use App::Sqitch::GUI::View::Panel::Change;
use App::Sqitch::GUI::View::Panel::Project;
use App::Sqitch::GUI::View::Panel::Plan;

use Data::Printer;

# Main window

# Optional, point: the upper-left corner of the app.
has 'position' => (
    is  => 'rw',
    isa => Maybe[WxPoint],
);

has 'style' => (
    is      => 'rw',
    isa     => Int,
    lazy    => 1,
    builder => '_build_style',
);

has 'frame' => (
    is      => 'rw',
    isa     => WxFrame,
    lazy    => 1,
    builder => '_build_frame',
);

has 'title' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    builder => '_build_title',
);

has 'size' => (
    is      => 'rw',
    isa     => WxSize,
    lazy    => 1,
    builder => '_build_size',
);

has 'menu_bar' => (
    is      => 'rw',
    isa     => SqitchGUIViewMenuBar,
    lazy    => 1,
    builder => '_build_menu_bar',
);

has 'status_bar' => (
    is      => 'rw',
    isa     => SqitchGUIViewStatusBar,
    lazy    => 1,
    builder => '_build_status_bar',
);

# Panels

has 'left_side' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelLeft,
    lazy    => 1,
    builder => '_build_left_side',
);

has 'right_side' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelRight,
    lazy    => 1,
    builder => '_build_right_side',
);

has 'top_side' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelTop,
    lazy    => 1,
    builder => '_build_top_side',
);

has 'project' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelProject,
    lazy    => 1,
    builder => '_build_project',
);

has 'plan' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelPlan,
    lazy    => 1,
    builder => '_build_plan',
);

has 'change' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelChange,
    lazy    => 1,
    builder => '_build_change',
);

has 'bottom_side' => (
    is      => 'rw',
    isa     => SqitchGUIViewPanelBottom,
    lazy    => 1,
    builder => '_build_bottom_side',
);

# Sizers
has 'main_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_main_sizer',
);

# Miscellaneous
has 'min_pane_size' => (
    is      => 'rw',
    isa     => Int,
    lazy    => 1,
    default => 50,
);

has 'sash_pos' => (
    is      => 'rw',
    isa     => Int,
    lazy    => 1,
    default => 450,
);

# Splitter window
has 'splitter_w' => (
    is      => 'rw',
    isa     => WxSplitterWindow,
    lazy    => 1,
    builder => '_build_splitter_w',
);

sub BUILD {
    my($self, @params) = @_;

    #Wx::EnableDefaultAssertHandler();        # Debug

    $self->frame->Hide;

    $self->frame->SetMenuBar($self->menu_bar);

    $self->main_sizer->Add( $self->left_side->panel,  1, wxEXPAND | wxALL, 0 );
    $self->main_sizer->Add( $self->right_side->panel, 0, wxEXPAND | wxALL, 0 );

    $self->left_side->sizer->Add( $self->splitter_w, 1, wxEXPAND | wxALL, 0 );

    $self->splitter_w->SplitHorizontally( $self->top_side->panel,
        $self->bottom_side->panel,
        $self->sash_pos );
    $self->splitter_w->SetMinimumPaneSize( $self->min_pane_size );

    $self->top_side->sizer->Add( $self->change->panel, 1, wxEXPAND | wxALL, 0 );
    $self->top_side->sizer->Add( $self->project->panel, 1, wxEXPAND | wxALL, 0 );
    $self->top_side->sizer->Add( $self->plan->panel, 1, wxEXPAND | wxALL, 0 );

    $self->top_side->panel->SetSizer( $self->top_side->sizer );

    $self->frame->SetSizer( $self->main_sizer );

    $self->change->panel->Show; # Gtk-WARNINGs if default is not Change
                                # later set to Project...  ;)

    $self->frame->Show;

    return $self;
}

sub _build_frame {
    my $self = shift;
    my $y = Wx::Frame->new(
        undef, -1,
        $self->title,
        $self->position || [-1, -1],
        $self->size,
        $self->style,
    );
    $y->Centre() unless $self->position;
    return $y;
}

sub _build_menu_bar {
    my $self = shift;
    p $self;
    say "_build_menu_bar";
    my $mb   = App::Sqitch::GUI::View::MenuBar->new(
        app      => $self->app,
        ancestor => $self,
        parent   => $self->frame,
    );
    say "done";
    return $mb;
}

sub _build_status_bar {
    my $self = shift;
    my $sb   = App::Sqitch::GUI::View::StatusBar->new(
        app      => $self->app,
        ancestor => $self,
        parent   => $self->frame,
    );
    return $sb;
}

sub _build_size {
    return Wx::Size->new(800, 650); # default window size
}

sub _build_style {
    my $self = shift;

    return wxCAPTION
         | wxCLOSE_BOX
         | wxMINIMIZE_BOX
         | wxMAXIMIZE_BOX
         | wxSYSTEM_MENU
         | wxRESIZE_BORDER
         | wxCLIP_CHILDREN;
}

sub _build_title {
    my $self = shift;
    return 'Sqitch Title';
}

sub _build_main_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_top_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_left_side {
    my $self = shift;

    my $panel = App::Sqitch::GUI::View::Panel::Left->new(
        app      => $self->app,
        parent   => $self->frame,
        ancestor => $self,
    );

    return $panel;
}

sub _build_right_side {
    my $self = shift;

    my $panel = App::Sqitch::GUI::View::Panel::Right->new(
        app      => $self->app,
        parent   => $self->frame,
        ancestor => $self,
    );

    return $panel;
}

sub _build_top_side {
    my $self = shift;

    return App::Sqitch::GUI::View::Panel::Top->new(
        app      => $self->app,
        parent   => $self->splitter_w,
        ancestor => $self,
    );
}

sub _build_project {
    my $self = shift;

    return App::Sqitch::GUI::View::Panel::Project->new(
        app      => $self->app,
        parent   => $self->top_side->panel,
        ancestor => $self,
    );
}

sub _build_plan {
    my $self = shift;
    return App::Sqitch::GUI::View::Panel::Plan->new(
        app      => $self->app,
        parent   => $self->top_side->panel,
        ancestor => $self,
    );
}

sub _build_change {
    my $self = shift;

    return App::Sqitch::GUI::View::Panel::Change->new(
        app      => $self->app,
        parent   => $self->top_side->panel,
        ancestor => $self,
    );
}

sub _build_bottom_side {
    my $self = shift;

    return App::Sqitch::GUI::View::Panel::Bottom->new(
        app      => $self->app,
        parent   => $self->splitter_w,
        ancestor => $self,
    );
}

sub _build_splitter_w {
    my $self = shift;

    my $spw = Wx::SplitterWindow->new(
        $self->left_side->panel,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxNO_FULL_REPAINT_ON_RESIZE | wxCLIP_CHILDREN
    );

    return $spw;
}

sub _set_events {
    my $self = shift;

    EVT_CLOSE( $self->frame, sub { $self->OnClose(@_) } );

    foreach my $name ( qw{change project plan} ) {
        my $btn = q{btn_} . $name;
        EVT_BUTTON $self->frame, $self->right_side->$btn->GetId, sub {
            $self->show_panel($name);
        };

        my $btn_sel = q{btn_} . $name . q{_sel};
        EVT_RADIOBUTTON $self->frame, $self->right_side->$btn_sel->GetId,
            sub { $self->on_radio($name); };
    }

    return 1;
}

sub show_panel {
    my ($self, $name) = @_;

    foreach my $panel ( qw{change project plan} ) {
        $self->$panel->panel->Show
            unless $self->$panel->panel->IsShown and $panel eq $name;

        $self->$panel->panel->Hide
            if $self->$panel->panel->IsShown and $panel ne $name;
    }

    my $btn_sel = q{btn_} . $name . q{_sel};
    $self->right_side->$btn_sel->SetValue(1);

    $self->top_side->panel->Layout();

    return;
}

sub control_write_s {
    my ( $self, $control, $value, $is_append ) = @_;

    $value ||= q{};                 # empty

    $control->ClearAll unless $is_append;
    $control->AppendText($value);
    $control->AppendText("\n");
    $control->Colourise( 0, $control->GetTextLength );

    return;
}

sub control_write_e {
    my ( $self, $control, $value ) = @_;

    $control->Clear;
    $control->SetValue($value) if defined $value;

    return;
}

sub combobox_write {
    my ( $self, $name ) = @_;
    $self->project->cbx_driver->SetValue($name) if $name;
    return;
}

sub set_status {
    my ($self, $state, $gui_rules) = @_;

    $self->status_bar->change_caption($state, 1);
    foreach my $btn ( keys %{$gui_rules} ) {
        my $enable = $gui_rules->{$btn};
        $self->right_side->$btn->Enable($enable);
    }
    $self->show_panel('project');

    return;
}

sub on_radio {
    my( $self, $name ) = @_;
    $self->show_panel($name);
    return;
}

sub OnClose {
    my ($self, $frame, $event) = @_;
    $event->Skip();
    return;
}

=head1 PANELS

 +-------------------------------------------------------------------+
 | +--Left---------------------------------------------+  +-Right--+ |
 | | +----------------------------------------Top----+ |  |        | |
 | | | +--Project/Change/Status--------------------+ | |  |        | |
 | | | |                                           | | |  |        | |
 | | | |                                           | | |  |        | |
 | | | |                                           | | |  |        | |
 | | | |                                           | | |  |        | |
 | | | |                                           | | |  |        | |
 | | | |                                           | | |  |        | |
 | | | |                                           | | |  |        | |
 | | | +-------------------------------------------' | |  |        | |
 | | +-----------------------------------------------' |  |        | |
 | | +----------------------------------------Bottom-+ |  |        | |
 | | |                                               | |  |        | |
 | | |                                               | |  |        | |
 | | |                                               | |  |        | |
 | | +-----------------------------------------------+ |  |        | |
 | +---------------------------------------------------+  +--------+ |
 +-------------------------------------------------------------------+

The sizer on C<< View::Panel::Top >> holds the
Project/Change/Status panels. This panels are initially hidden and are
showed one by one using the buttons on the right panel, like a
notebook, but with independent buttons.

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

1;    # End of App::Sqitch::GUI::View
