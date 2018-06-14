package App::Sqitch::GUI::View;

# ABSTRACT: The View

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    ArrayRef
    Int
    Maybe
    SqitchGUIModel
    SqitchGUIViewPanelBottom
    SqitchGUIViewPanelChange
    SqitchGUIViewPanelLeft
    SqitchGUIViewPanelPlan
    SqitchGUIViewPanelProject
    SqitchGUIViewPanelRight
    SqitchGUIViewPanelTop
    SqitchGUIWxStatusbar
    SqitchGUIWxToolbar
    Str
    WxFrame
    WxPoint
    WxSize
    WxSizer
    WxSplitterWindow
);
use Wx qw(:everything);
use Wx::Event qw(
    EVT_BUTTON
    EVT_CLOSE
    EVT_LIST_ITEM_SELECTED
    EVT_MENU
    EVT_RADIOBUTTON
    EVT_TOOL
    EVT_TIMER
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::Config::Toolbar;
use App::Sqitch::GUI::Wx::Menubar;
use App::Sqitch::GUI::Wx::Toolbar;
use App::Sqitch::GUI::Wx::Statusbar;
use App::Sqitch::GUI::View::Panel::Left;
use App::Sqitch::GUI::View::Panel::Right;
use App::Sqitch::GUI::View::Panel::Top;
use App::Sqitch::GUI::View::Panel::Bottom;
use App::Sqitch::GUI::View::Panel::Change;
use App::Sqitch::GUI::View::Panel::Project;
use App::Sqitch::GUI::View::Panel::Plan;

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
    is      => 'ro',
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

has 'tool_bar' => (
    is      => 'ro',
    isa     => SqitchGUIWxToolbar,
    lazy    => 1,
    builder => '_build_tool_bar',
);

has 'status_bar' => (
    is      => 'ro',
    isa     => SqitchGUIWxStatusbar,
    lazy    => 1,
    builder => '_build_status_bar',
);

# Panels

has 'left' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelLeft,
    lazy    => 1,
    builder => '_build_left',
);

has 'right' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelRight,
    lazy    => 1,
    builder => '_build_right',
);

has 'top' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelTop,
    lazy    => 1,
    builder => '_build_top',
);

has 'project' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelProject,
    lazy    => 1,
    builder => '_build_project',
);

has 'plan' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelPlan,
    lazy    => 1,
    builder => '_build_plan',
);

has 'change' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelChange,
    lazy    => 1,
    builder => '_build_change',
);

has 'bottom' => (
    is      => 'ro',
    isa     => SqitchGUIViewPanelBottom,
    lazy    => 1,
    builder => '_build_bottom',
);

# Sizers
has 'main_sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_main_sizer',
);

# Miscellaneous
has 'min_pane_size' => (
    is      => 'ro',
    isa     => Int,
    lazy    => 1,
    default => 50,
);

has 'sash_pos' => (
    is      => 'ro',
    isa     => Int,
    lazy    => 1,
    default => 450,
);

# Splitter window
has 'splitter_w' => (
    is      => 'ro',
    isa     => WxSplitterWindow,
    lazy    => 1,
    builder => '_build_splitter_w',
);

has 'model' => (
    is      => 'ro',
    isa     => SqitchGUIModel,
    lazy    => 1,
    default => sub {
        shift->app->model;
    },
);

sub BUILD {
    my($self, @params) = @_;

    #Wx::EnableDefaultAssertHandler();        # Debug

    $self->frame->Hide;

    # Menu Bar
    my $menu = App::Sqitch::GUI::Wx::Menubar->new(
        app       => $self->app,
        ancestor  => $self,
        parent    => $self->frame,
    );
    $self->frame->SetMenuBar( $menu->menu_bar );

    # Tool Bar
    my $conf     = App::Sqitch::GUI::Config::Toolbar->new;
    my @toolbars = $conf->all_buttons;
    my $tb = $self->tool_bar;
    foreach my $name (@toolbars) {
        my $attribs = $conf->get_tool($name);
        $tb->make_toolbar_button( $name, $attribs );
    }
    $tb->set_initial_mode( \@toolbars );
    $self->frame->SetToolBar($tb);
    $tb->Realize;

    $self->main_sizer->Add( $self->left->panel,  1, wxEXPAND | wxALL, 0 );
    $self->main_sizer->Add( $self->right->panel, 0, wxEXPAND | wxALL, 0 );

    $self->left->sizer->Add( $self->splitter_w, 1, wxEXPAND | wxALL, 0 );

    $self->splitter_w->SplitHorizontally( $self->top->panel,
        $self->bottom->panel,
        $self->sash_pos );
    $self->splitter_w->SetMinimumPaneSize( $self->min_pane_size );

    $self->top->sizer->Add( $self->change->panel, 1, wxEXPAND | wxALL, 0 );
    $self->top->sizer->Add( $self->project->panel, 1, wxEXPAND | wxALL, 0 );
    $self->top->sizer->Add( $self->plan->panel, 1, wxEXPAND | wxALL, 0 );

    $self->top->panel->SetSizer( $self->top->sizer );

    $self->frame->SetSizer( $self->main_sizer );

    if ($^O ne 'MSWin32') {
        $self->change->panel->Show; # Gtk-WARNINGs if default is not Change
                                    # later set to Project...  ;)
    }
    else {
        $self->project->panel->Show;
    }

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

sub _build_tool_bar {
    my $self = shift;
    my $tb = App::Sqitch::GUI::Wx::Toolbar->new(
        app       => $self->app,
        ancestor  => $self,
        parent    => $self->frame,
        icon_path => $self->app->config->icon_path,
    );
    return $tb;
}

sub _build_status_bar {
    my $self = shift;
    my $sb   = App::Sqitch::GUI::Wx::Statusbar->new(
        app      => $self->app,
        ancestor => $self,
        parent   => $self->frame,
    );
    return $sb;
}

sub _build_size {
    return Wx::Size->new(1024, 768); # default window size
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

sub _build_left {
    my $self = shift;

    my $panel = App::Sqitch::GUI::View::Panel::Left->new(
        app      => $self->app,
        parent   => $self->frame,
        ancestor => $self,
    );

    return $panel;
}

sub _build_right {
    my $self = shift;

    my $panel = App::Sqitch::GUI::View::Panel::Right->new(
        app      => $self->app,
        parent   => $self->frame,
        ancestor => $self,
    );

    return $panel;
}

sub _build_top {
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
        parent   => $self->top->panel,
        ancestor => $self,
    );
}

sub _build_plan {
    my $self = shift;
    return App::Sqitch::GUI::View::Panel::Plan->new(
        app       => $self->app,
        parent    => $self->top->panel,
        ancestor  => $self,
        list_data => $self->model->plan_list_data,
    );
}

sub _build_change {
    my $self = shift;

    return App::Sqitch::GUI::View::Panel::Change->new(
        app      => $self->app,
        parent   => $self->top->panel,
        ancestor => $self,
    );
}

sub _build_bottom {
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
        $self->left->panel,
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
        EVT_BUTTON $self->frame, $self->right->$btn->GetId, sub {
            $self->show_panel($name);
        };

        my $btn_sel = q{btn_} . $name . q{_sel};
        EVT_RADIOBUTTON $self->frame, $self->right->$btn_sel->GetId,
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
    $self->right->$btn_sel->SetValue(1);

    $self->top->panel->Layout();

    return;
}

sub set_status_bar {
    my ( $self, $state, $gui_rules ) = @_;

    $self->status_bar->change_caption( $state, 1 );
    foreach my $btn ( keys %{$gui_rules} ) {
        my $enable = $gui_rules->{$btn};
        $self->right->$btn->Enable($enable);
    }
    my $timer = Wx::Timer->new( $self->frame, 1 );
    $timer->Start( 200, 1 );    # one shot
    EVT_TIMER $self->frame, 1, sub {
        $self->show_panel('project');
    };
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

sub get_toolbar_btn {
    my ( $self, $name ) = @_;
    return $self->tool_bar->get_toolbar_btn($name);
}

sub event_handler_for_tb_button {
    my ( $self, $name, $calllback ) = @_;
    my $tb_id = $self->get_toolbar_btn($name)->GetId;
    EVT_TOOL $self->frame, $tb_id, $calllback;
    return;
}

sub event_handler_for_list {
    my ( $self, $list, $calllback ) = @_;
    EVT_LIST_ITEM_SELECTED $self->frame, $list, $calllback;
    return;
}

sub load_txt_form_for {
    my ($self, $form, $field, $value) = @_;
    hurl 'Wrong arguments passed to load_txt_form_for()'
        unless defined $field;
    my $name    = "txt_$field";
    my $control = $self->$form->$name;
    $self->$form->control_write_e($control, $value);
    return;
}

sub load_sql_form_for {
    my ($self, $form, $command, $value) = @_;
    my $name    = "edit_$command";
    my $control = $self->$form->$name;
    $self->$form->control_write_stc($control, $value);
}

sub get_plan_list_ctrl {
    my $self = shift;
    return $self->plan->list_ctrl;
}

sub get_project_list_ctrl {
    my $self = shift;
    return $self->project->list_ctrl;
}

sub log_message {
    my ($self, $msg, $newline) = @_;
    my $control = $self->bottom->log_ctrl;
    $self->bottom->control_write_stc($control, $msg, 'append', $newline);
    $control->ScrollToLine( $control->GetLineCount );
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
