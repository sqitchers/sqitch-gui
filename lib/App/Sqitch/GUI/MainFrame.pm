package App::Sqitch::GUI::MainFrame;

use strict;
use warnings;

use Moose;
use Wx qw<:everything>;
use Wx::Event qw<EVT_CLOSE EVT_BUTTON EVT_MENU>;

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::MainFrame::MenuBar;
use App::Sqitch::GUI::MainFrame::StatusBar;
use App::Sqitch::GUI::MainFrame::MainPanel;

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

has 'main_panel' => (
    is          => 'rw',
    isa         => 'App::Sqitch::GUI::MainFrame::MainPanel',
    lazy_build  => 1,
    clearer     => 'clear_main_panel',
    predicate   => 'has_main_panel',
);

has 'main_panel_sizer' => (is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

sub BUILD {
    my($self, @params) = @_;

    $self->frame->Show(0);

    $self->frame->SetMenuBar($self->menu_bar);
    $self->_build_status_bar;

    $self->main_panel_sizer->Add( $self->main_panel->main_panel, 1, wxEXPAND );
    $self->frame->SetSizer($self->main_panel_sizer);

    # my $log = Wx::LogTextCtrl->new($comment);
    # $self->{old_log} = Wx::Log::SetActiveTarget( $log );

    $self->_set_events;

    $self->frame->Show(1);

    # Wx::LogMessage('Welcomme to Sqitch-GUI');

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
    my $self = shift;

    ### This is fucked up.  If I start with a Wx::Size object using the
    ### constructor, the resulting window ends up being way too small, as
    ### if it received no size specification.
    #my $s = Wx::Size->new(800,700);     # Broke

    ### But if I start with a wxDefaultSize object, I can then call
    ### SetWidth and SetHeight on it and end up with the specified dimensions.
    my $s = wxDefaultSize;             # works

    ### Maintain the h/w most recently set by the user
    my ( $w, $h ) = ( 800, 600 );    # defaults

    ### Obviously must be called if we started with the wxDefaultSize
    ### constant.
    ### If we start with the constructor, this shouldn't be necessary.
    ### But in that case, this actually has no effect at all whether it's
    ### called or not.
    $s->SetWidth($w);
    $s->SetHeight($h);

    ### Regardless of which method of generating $s you used, the
    ### following all produce the same output.
    ### But only starting with wxDefaultSize has any effect on the actual
    ### starting size of the app.
    #say ref $s;
    #say $s->width;
    #say $s->height;
    #say $s->IsFullySpecified;

    return $s;
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

sub _build_main_panel_sizer {
    my $self = shift;
    my $ips = Wx::BoxSizer->new(wxHORIZONTAL);
    return $ips;
}

sub _build_main_panel {
    my $self = shift;
    return App::Sqitch::GUI::MainFrame::MainPanel->new(
        app         => $self->app,
        ancestor    => $self,
        parent      => $self->frame,
    );
}

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
