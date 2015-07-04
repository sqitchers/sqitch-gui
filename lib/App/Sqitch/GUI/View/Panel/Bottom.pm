package App::Sqitch::GUI::View::Panel::Bottom;

# ABSTRACT: The Bottom Panel

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    ArrayRef
    Maybe
    Object
	SqitchGUIWxLogView
    WxPanel
    WxSizer
    WxTextCtrl
);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

with qw(App::Sqitch::GUI::Roles::Element
        App::Sqitch::GUI::Roles::Panel);

use App::Sqitch::GUI::Wx::LogView;

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

has 'log_ctrl' => (
    is      => 'ro',
    isa     => SqitchGUIWxLogView,
    lazy    => 1,
    builder => '_build_log_ctrl',
);

sub _build_log_ctrl {
    my $self = shift;
	my $log_ctrl = App::Sqitch::GUI::Wx::LogView->new(
        app      => $self->app,
        parent   => $self->panel,
        ancestor => $self,
    );
	$log_ctrl->SetReadOnly(1);					 # log is readonly
	return $log_ctrl;
}

sub BUILD {
    my $self = shift;

    #-   The main panel

    $self->panel->Show(0);
    $self->panel->SetSizer( $self->sizer );

    #--  Log control on the left-bottom side

    $self->sizer->Add( $self->log_ctrl, 1, wxEXPAND | wxALL, 5 );

    #--

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
    #$panel->SetBackgroundColour(Wx::Colour->new('blue'));
    #$panel->SetBackgroundColour( $self->parent->GetBackgroundColour );

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _set_events { }

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

1;    # End of App::Sqitch::GUI::View::Panel::Bottom
