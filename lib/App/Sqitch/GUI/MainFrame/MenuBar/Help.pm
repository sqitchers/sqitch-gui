package App::Sqitch::GUI::MainFrame::MenuBar::Help;

use Moose;
use namespace::autoclean;
use Wx qw(:everything);
use Wx::Event qw(EVT_MENU);

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::MainFrame::Dialog::Help;
use App::Sqitch::GUI::MainFrame::Dialog::About;

### Wx::Menu is a non-hash object.  Extending such requires
### MooseX::NonMoose::InsideOut instead of plain MooseX::NonMoose.
use MooseX::NonMoose::InsideOut;
extends 'Wx::Menu';

has 'itm_help'  => (is => 'rw', isa => 'Wx::MenuItem',  lazy_build => 1);
has 'itm_about' => (is => 'rw', isa => 'Wx::MenuItem',  lazy_build => 1);

sub FOREIGNBUILDARGS {
    return;                       # Wx::Menu->new() takes no arguments
}

sub BUILD {
    my $self = shift;
    $self->Append( $self->itm_about );
    $self->Append( $self->itm_help );
    return $self;
}

sub _build_itm_help {
    my $self = shift;
    return Wx::MenuItem->new(
        $self,
        wxID_HELP,
        '&Help',
        'Show HTML help',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

sub _build_itm_about {
    my $self = shift;
    return Wx::MenuItem->new(
        $self,
        wxID_ABOUT,
        '&About',
        'Show about dialog',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

sub _set_events {
    my $self = shift;
    EVT_MENU($self->parent, $self->itm_about->GetId, sub{$self->OnAbout(@_)});
    EVT_MENU($self->parent, $self->itm_help->GetId, sub{$self->OnHelp(@_)});
    return 1;
}

sub OnAbout {
    my $self  = shift;
    my $frame = shift;  # Wx::Frame
    my $event = shift;  # Wx::CommandEvent
    my $d = App::Sqitch::GUI::MainFrame::Dialog::About->new(
        app         => $self->app,
        ancestor    => $self,
        parent      => undef,
    );
    $d->show();
    return 1;
}

sub OnHelp {
    my $self  = shift;
    my $frame = shift;  # Wx::Frame
    my $event = shift;  # Wx::CommandEvent
    my $d = App::Sqitch::GUI::MainFrame::Dialog::Help->new(
        app         => $self->app,
        ancestor    => $self,
        parent      => undef,
    );
    return 1;
}

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

1;    # End of App::Sqitch::GUI::MainFrame::MenuBar::Help
