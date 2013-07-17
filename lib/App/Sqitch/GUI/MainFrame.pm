package App::Sqitch::GUI::MainFrame;

use strict;
use warnings;

use Moose;
use Wx qw<:everything>;
use Wx::Event qw<EVT_CLOSE EVT_BUTTON EVT_MENU>;

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::MainFrame::MenuBar;
use App::Sqitch::GUI::MainFrame::StatusBar;
#use App::Sqitch::GUI::MainFrame::MainPanel;
#use App::Sqitch::GUI::MainFrame::BFGPane;

# Main window
has 'position' => (
    is            => 'rw',
    isa           => 'Maybe[Wx::Point]',
    documentation => q{ Optional, point: the upper-left corner of the app. }
);
has 'style' => ( is => 'rw', isa => 'Int',       lazy_build => 1 );
has 'frame' => ( is => 'rw', isa => 'Wx::Frame', lazy_build => 1 );
has 'title' => ( is => 'rw', isa => 'Str',       lazy_build => 1 );
has 'size'  => ( is => 'rw', isa => 'Wx::Size',  lazy_build => 1 );
has 'menu_bar' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::MenuBar',
    lazy_build => 1,
);
has 'status_bar' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::StatusBar',
    lazy_build => 1,
);

# Panels
has 'left_panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'right_panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );

# Sizers
has 'main_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

# Miscellaneous
has 'min_pane_size' => ( is => 'rw', isa => 'Int', lazy => 1, default => 50 );
has 'sash_pos' => ( is => 'rw', isa => 'Int', lazy => 1, default => 450 );

sub BUILD {
    my($self, @params) = @_;

    $self->frame->Show(0);

    $self->frame->SetMenuBar($self->menu_bar);
    $self->_build_status_bar;

    my $panel1 = $self->left_panel;
    my $panel2 = $self->right_panel;

    $self->main_sizer->Add($self->left_panel,  1, wxEXPAND);
    $self->main_sizer->Add($self->right_panel, 1, wxEXPAND);

    my $panel1_bsz = Wx::BoxSizer->new(wxHORIZONTAL);
    $self->left_panel->SetSizer($panel1_bsz);

    my $panel2_bsz = Wx::BoxSizer->new(wxHORIZONTAL);
    $panel2->SetSizer($panel2_bsz);

    my $spw = Wx::SplitterWindow->new(
        $panel1, -1, [-1, -1], [-1, -1],
        wxNO_FULL_REPAINT_ON_RESIZE | wxCLIP_CHILDREN );

    $panel1_bsz->Add($spw, 1, wxEXPAND);

    my $sp1 = Wx::Panel->new($spw, -1);
    my $sp2 = Wx::Panel->new($spw, -1);

    $sp1->SetBackgroundColour( Wx::Colour->new("pink") );
    $sp2->SetBackgroundColour( Wx::Colour->new("sky blue") );

    $spw->SplitHorizontally($sp1, $sp2, $self->sash_pos);
    #$spw->SetMinimumPaneSize( $self->min_pane_size );

    $self->frame->SetSizer($self->main_sizer);

    $self->_set_events;

    $self->frame->Show(1);

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

sub _build_left_panel {
    my $self = shift;

    my $panel = Wx::Panel->new(
        $self->frame,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxFULL_REPAINT_ON_RESIZE,
        'mainPanel',
    );
    $panel->SetBackgroundColour( Wx::Colour->new('tan') );

    return $panel;
}

sub _build_right_panel {
    my $self = shift;

    my $panel = Wx::Panel->new(
        $self->frame,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxFULL_REPAINT_ON_RESIZE,
        'mainPanel',
    );
    $panel->SetBackgroundColour( Wx::Colour->new('red') );

    return $panel;
}

sub _build_menu_bar {
    my $self = shift;
    my $mb   = App::Sqitch::GUI::MainFrame::MenuBar->new(
        app      => $self->app,
        ancestor => $self,
        parent   => $self->frame
    );
    return $mb;
}

sub _build_status_bar {
    my $self = shift;
    my $sb   = App::Sqitch::GUI::MainFrame::StatusBar->new(
        app      => $self->app,
        ancestor => $self,
        parent   => $self->frame
    );
    return $sb;
}

sub _build_size {
    return Wx::Size->new(800, 600); # default window size
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

# sub _build_proj_panel {
#     my $self = shift;

#     return App::Sqitch::GUI::MainFrame::BFGPane->new(
#         app      => $self->app,
#         parent   => $self->frame,
#         ancestor => $self,
#     );
# }

# sub _build_main_panel_sizer {
#     return Wx::BoxSizer->new(wxHORIZONTAL);
# }

# sub _build_main_panel {
#     my $self = shift;
#     return App::Sqitch::GUI::MainFrame::MainPanel->new(
#         app         => $self->app,
#         parent      => $self->frame,
#         ancestor    => $self,
#     );
# }

sub _set_events {
    my $self = shift;
    EVT_CLOSE( $self->frame, sub { $self->OnClose(@_) } );
    return;
}

sub OnClose {
    my ($self, $frame, $event) = @_;
    $event->Skip();
    return;
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

1;    # End of App::Sqitch::GUI::MainFrame
