package App::Sqitch::GUI::View::Panel::Top;

# ABSTRACT: The Top Panel

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxPanel
    WxSizer
);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

with 'App::Sqitch::GUI::Roles::Element';

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

sub BUILD {
    my $self = shift;

    $self->panel->Show(0);
    $self->panel->SetSizer( $self->sizer );
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
    #$panel->SetBackgroundColour(Wx::Colour->new('yellow'));

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _set_events { }

sub OnClose {
    my ($self, $event) = @_;
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

  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::Panel::Top
