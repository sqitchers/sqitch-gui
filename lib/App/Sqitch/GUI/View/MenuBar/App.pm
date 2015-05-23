package App::Sqitch::GUI::View::MenuBar::App;

use 5.010;
use strict;
use warnings;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxMenuItem
);
use Wx qw(:everything);
use Wx::Event qw(EVT_MENU);

with 'App::Sqitch::GUI::Roles::Element';

extends 'Wx::Menu';

has 'itm_quit' => (
    is      => 'rw',
    isa     => WxMenuItem,
    lazy    => 1,
    builder => '_build_itm_quit',
);

sub FOREIGNBUILDARGS {
    return ();                    # Wx::Menu->new() takes no arguments
}

sub BUILD {
    my $self = shift;
    $self->Append( $self->itm_quit );
    return $self;
}

sub _build_itm_quit {
    my $self = shift;
    return Wx::MenuItem->new(
        $self,
        wxID_EXIT,
        '&Quit',
        'Quit',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

sub _set_events {
    my $self = shift;
    return 1;
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

1;    # End of App::Sqitch::GUI::View::MenuBar::App
